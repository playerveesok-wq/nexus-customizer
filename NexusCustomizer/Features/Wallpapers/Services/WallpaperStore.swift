import UIKit
import ImageIO
import UniformTypeIdentifiers

enum WallpaperError: LocalizedError {
    case unreadable, notAnImage, empty, tooLarge, notEnoughSpace, io(Error)
    var errorDescription: String? {
        switch self {
        case .unreadable: "Не удалось прочитать файл."
        case .notAnImage: "Файл не является изображением."
        case .empty: "Файл пуст."
        case .tooLarge: "Файл слишком большой (макс. 50 МБ)."
        case .notEnoughSpace: "Недостаточно места."
        case .io(let e): "Ошибка: \(e.localizedDescription)"
        }
    }
}

actor WallpaperStore {
    static let shared = WallpaperStore()
    private let fm = FileManager.default
    private let root: URL
    private let thumbsDir: URL
    private let indexURL: URL
    private let maxFileBytes: Int64 = 50 * 1024 * 1024
    private var items: [WallpaperItem] = []
    private let memoryCache = NSCache<NSString, UIImage>()
    private struct Index: Codable { var version = 1; var items: [WallpaperItem] }

    init() {
        let docs   = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        root      = docs.appendingPathComponent("Wallpapers", isDirectory: true)
        thumbsDir = caches.appendingPathComponent("WallpaperThumbs", isDirectory: true)
        indexURL  = root.appendingPathComponent("index.json")
        memoryCache.countLimit = 60
    }

    nonisolated func url(for item: WallpaperItem) -> URL {
        root.appendingPathComponent(item.fileName)
    }

    func loadAll() throws -> [WallpaperItem] {
        try prepareDirectories()
        var loaded: [WallpaperItem] = []
        if let data = try? Data(contentsOf: indexURL),
           let index = try? JSONDecoder().decode(Index.self, from: data) {
            loaded = index.items
        }
        loaded = loaded.filter { fm.fileExists(atPath: root.appendingPathComponent($0.fileName).path) }
        let known = Set(loaded.map(\.fileName))
        let files = (try? fm.contentsOfDirectory(atPath: root.path)) ?? []
        for name in files where name != "index.json" && !known.contains(name) && !name.hasPrefix(".") {
            let id = UUID(uuidString: (name as NSString).deletingPathExtension) ?? UUID()
            if let item = try? makeItem(id: id, fileName: name) { loaded.append(item) }
        }
        items = loaded.sorted { $0.createdAt > $1.createdAt }
        try saveIndex()
        return items
    }

    func importFile(at staged: URL) throws -> WallpaperItem {
        defer { try? fm.removeItem(at: staged) }
        try prepareDirectories()
        let size = (try? fm.attributesOfItem(atPath: staged.path)[.size] as? NSNumber)?.int64Value ?? 0
        guard size > 0 else { throw WallpaperError.empty }
        guard size <= maxFileBytes else { throw WallpaperError.tooLarge }
        try ensureFreeSpace(for: size)
        guard let source = CGImageSourceCreateWithURL(staged as CFURL, nil),
              CGImageSourceGetCount(source) > 0,
              let typeID = CGImageSourceGetType(source) as String?,
              let type = UTType(typeID), type.conforms(to: .image)
        else { throw WallpaperError.notAnImage }
        let ext = type.preferredFilenameExtension ?? "img"
        let id = UUID()
        let fileName = "\(id.uuidString).\(ext)"
        let destination = root.appendingPathComponent(fileName)
        do { try fm.moveItem(at: staged, to: destination) } catch { throw WallpaperError.io(error) }
        do {
            let item = try makeItem(id: id, fileName: fileName)
            items.insert(item, at: 0)
            try saveIndex()
            return item
        } catch {
            items.removeAll { $0.id == id }
            try? fm.removeItem(at: destination)
            throw error as? WallpaperError ?? WallpaperError.io(error)
        }
    }

    func delete(_ item: WallpaperItem) throws {
        try? fm.removeItem(at: url(for: item))
        items.removeAll { $0.id == item.id }
        try saveIndex()
    }

    func thumbnail(for item: WallpaperItem, maxPixel: CGFloat) -> UIImage? {
        let key = "\(item.id)-\(Int(maxPixel))" as NSString
        if let cached = memoryCache.object(forKey: key) { return cached }
        guard let image = ImageProcessing.thumbnail(at: url(for: item), maxPixel: maxPixel) else { return nil }
        memoryCache.setObject(image, forKey: key)
        return image
    }

    func animatedImage(for item: WallpaperItem, maxPixel: CGFloat) -> UIImage? {
        ImageProcessing.animatedImage(at: url(for: item), maxPixel: maxPixel)
    }

    private func prepareDirectories() throws {
        do {
            try fm.createDirectory(at: root, withIntermediateDirectories: true)
            try fm.createDirectory(at: thumbsDir, withIntermediateDirectories: true)
        } catch { throw WallpaperError.io(error) }
    }

    private func makeItem(id: UUID, fileName: String) throws -> WallpaperItem {
        let url = root.appendingPathComponent(fileName)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else { throw WallpaperError.notAnImage }
        let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let created = (try? fm.attributesOfItem(atPath: url.path)[.creationDate] as? Date) ?? Date()
        return WallpaperItem(id: id, fileName: fileName, isAnimated: CGImageSourceGetCount(source) > 1, pixelWidth: props?[kCGImagePropertyPixelWidth] as? Int ?? 0, pixelHeight: props?[kCGImagePropertyPixelHeight] as? Int ?? 0, createdAt: created)
    }

    private func saveIndex() throws {
        do {
            let data = try JSONEncoder().encode(Index(items: items))
            try data.write(to: indexURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        } catch { throw WallpaperError.io(error) }
    }

    private func ensureFreeSpace(for bytes: Int64) throws {
        let values = try? root.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let free = values?.volumeAvailableCapacityForImportantUsage, free < bytes * 2 + 50 * 1024 * 1024 {
            throw WallpaperError.notEnoughSpace
        }
    }
}
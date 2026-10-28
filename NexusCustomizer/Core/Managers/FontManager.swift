import SwiftUI
import CoreText
import UniformTypeIdentifiers
import Observation

struct CustomFontItem: Identifiable, Codable, Hashable {
    let id: UUID
    let displayName: String
    let postScriptName: String
    let fileName: String
}

@Observable
final class FontManager {
    private let selectedFontKey = "nexus.selected.font.psname"
    private let metadataFileName = "fonts_metadata.json"
    
    var customFonts: [CustomFontItem] = []
    var selectedPostScriptName: String? {
        didSet { UserDefaults.standard.set(selectedPostScriptName, forKey: selectedFontKey) }
    }
    
    private var fontsDirectoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("CustomFonts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    init() {
        self.selectedPostScriptName = UserDefaults.standard.string(forKey: selectedFontKey)
        loadAndRegisterSavedFonts()
    }
    
    func selectSystemFont() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedPostScriptName = nil
        }
    }
    
    func selectFont(_ item: CustomFontItem) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedPostScriptName = item.postScriptName
        }
    }
    
    func importFont(from sourceURL: URL) async throws {
        let dirURL = fontsDirectoryURL
        let metadataURL = dirURL.appendingPathComponent(metadataFileName)
        let currentItems = customFonts
        
        let newFontItem: CustomFontItem = try await Task.detached(priority: .userInitiated) {
            let scoped = sourceURL.startAccessingSecurityScopedResource()
            defer { if scoped { sourceURL.stopAccessingSecurityScopedResource() } }
            
            let fileName = sourceURL.lastPathComponent
            let destinationURL = dirURL.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            var cfError: Unmanaged<CFError>?
            let registered = CTFontManagerRegisterFontsForURL(destinationURL as CFURL, .process, &cfError)
            
            if !registered, let err = cfError?.takeRetainedValue() {
                let nsErr = err as Error as NSError
                if nsErr.code != CTFontManagerError.alreadyRegistered.rawValue {
                    throw nsErr
                }
            }
            
            guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(destinationURL as CFURL) as? [CTFontDescriptor],
                  let firstDescriptor = descriptors.first,
                  let psName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontNameAttribute) as? String else {
                throw NSError(domain: "FontManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid font file"])
            }
            
            let displayName = (CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontDisplayNameAttribute) as? String) ?? psName
            
            let item = CustomFontItem(id: UUID(), displayName: displayName, postScriptName: psName, fileName: fileName)
            
            var updated = currentItems.filter { $0.postScriptName != psName }
            updated.append(item)
            
            let data = try JSONEncoder().encode(updated)
            try data.write(to: metadataURL, options: .atomic)
            
            return item
        }.value
        
        await MainActor.run {
            customFonts.removeAll { $0.postScriptName == newFontItem.postScriptName }
            customFonts.append(newFontItem)
            selectedPostScriptName = newFontItem.postScriptName
        }
    }
    
    private func loadAndRegisterSavedFonts() {
        let dirURL = fontsDirectoryURL
        let metadataURL = dirURL.appendingPathComponent(metadataFileName)
        
        guard let data = try? Data(contentsOf: metadataURL),
              let saved = try? JSONDecoder().decode([CustomFontItem].self, from: data) else { return }
        
        for item in saved {
            let fileURL = dirURL.appendingPathComponent(item.fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, nil)
            }
        }
        self.customFonts = saved
    }
}

struct NexusTypographyModifier: ViewModifier {
    @Environment(FontManager.self) private var fontManager
    var size: CGFloat
    var relativeTo: Font.TextStyle
    
    func body(content: Content) -> some View {
        if let psName = fontManager.selectedPostScriptName {
            content.font(.custom(psName, size: size, relativeTo: relativeTo))
        } else {
            content.font(.system(size: size, design: .default))
        }
    }
}

extension View {
    func applyNexusTypography(size: CGFloat = 16, relativeTo: Font.TextStyle = .body) -> some View {
        modifier(NexusTypographyModifier(size: size, relativeTo: relativeTo))
    }
}

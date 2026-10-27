import SwiftUI
import PhotosUI
import Observation

@MainActor
@Observable
final class WallpapersViewModel {
    private(set) var items: [WallpaperItem] = []
    private(set) var selectedID: UUID?
    private(set) var isImporting = false
    var errorMessage: String?

    @ObservationIgnored private let store: WallpaperStore
    @ObservationIgnored private let selectedKey = "selectedWallpaperID"

    init(store: WallpaperStore = .shared) {
        self.store = store
        selectedID = UserDefaults.standard.string(forKey: selectedKey).flatMap(UUID.init)
        Task { await load() }
    }

    var selectedItem: WallpaperItem? { items.first { $0.id == selectedID } }

    func load() async {
        do {
            items = try await store.loadAll()
            if let id = selectedID, !items.contains(where: { $0.id == id }) { select(nil) }
        } catch { errorMessage = error.localizedDescription }
    }

    func importPicked(_ results: [PHPickerResult]) async {
        guard !results.isEmpty else { return }
        isImporting = true
        defer { isImporting = false }

        var failed = 0
        var lastError: Error?
        for result in results {
            do {
                let staged = try await ProviderLoader.stageFile(from: result.itemProvider)
                let item = try await store.importFile(at: staged)
                items.insert(item, at: 0)
                if selectedID == nil { select(item.id) }
            } catch {
                failed += 1
                lastError = error
            }
        }
        if failed > 0 {
            errorMessage = failed == results.count
                ? (lastError?.localizedDescription ?? "Не удалось импортировать.")
                : "Не удалось импортировать файлов: \(failed) из \(results.count)."
        }
    }

    func select(_ id: UUID?) {
        selectedID = id
        UserDefaults.standard.set(id?.uuidString, forKey: selectedKey)
    }

    func delete(_ item: WallpaperItem) async {
        do {
            try await store.delete(item)
            items.removeAll { $0.id == item.id }
            if selectedID == item.id { select(nil) }
        } catch { errorMessage = error.localizedDescription }
    }
}

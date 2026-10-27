import Foundation
import UniformTypeIdentifiers

enum ProviderLoader {
    static func stageFile(from provider: NSItemProvider) async throws -> URL {
        let type: UTType = provider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) ? .gif : .image
        return try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
                guard let url else {
                    continuation.resume(throwing: error ?? WallpaperError.unreadable)
                    return
                }
                do {
                    let staged = FileManager.default.temporaryDirectory
                        .appendingPathComponent("import-\(UUID().uuidString)")
                        .appendingPathExtension(url.pathExtension)
                    try FileManager.default.copyItem(at: url, to: staged)
                    continuation.resume(returning: staged)
                } catch {
                    continuation.resume(throwing: WallpaperError.io(error))
                }
            }
        }
    }
}
import Foundation

struct WallpaperItem: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let fileName: String
    let isAnimated: Bool
    let pixelWidth: Int
    let pixelHeight: Int
    let createdAt: Date
}

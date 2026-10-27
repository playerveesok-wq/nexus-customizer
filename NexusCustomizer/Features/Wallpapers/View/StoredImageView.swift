import SwiftUI
import UIKit
struct StoredImageView: View {
    let item: WallpaperItem
    let maxPixel: CGFloat
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.white.opacity(0.06)
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
                    .transition(.opacity)
            } else {
                ProgressView().tint(.white.opacity(0.6))
            }
        }
        .animation(.easeOut(duration: 0.25), value: image != nil)
        .task(id: item.id) {
            image = await WallpaperStore.shared.thumbnail(for: item, maxPixel: maxPixel)
        }
    }
}

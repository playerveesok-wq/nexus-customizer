import SwiftUI
import UIKit
import Observation
struct WallpaperPreviewView: View {
    let item: WallpaperItem
    let isSelected: Bool
    let onUse: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var animated: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let animated, item.isAnimated {
                AnimatedImageView(image: animated).ignoresSafeArea()
            } else {
                StoredImageView(item: item, maxPixel: 1600).ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.headline).foregroundStyle(.white)
                            .padding(12).background(.ultraThinMaterial, in: Circle())
                    }
                }
                Spacer()
                Button {
                    onUse(); dismiss()
                } label: {
                    Text(isSelected ? "Уже выбрано" : "Использовать")
                        .fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Theme.accent, in: Capsule())
                }
                .disabled(isSelected)
            }
            .padding(20)
        }
        .task {
            if item.isAnimated {
                animated = await WallpaperStore.shared.animatedImage(for: item, maxPixel: 800)
            }
        }
    }
}

import SwiftUI

struct SettingsView: View {
    @AppStorage("reduceAppAnimations") private var reduceAnimations = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(title: "Настройки", subtitle: "Оптимизация и хранилище")

                VStack(spacing: 0) {
                    Toggle(isOn: $reduceAnimations) {
                        Label("Отключить анимации интерфейса", systemImage: "wand.and.sparkles.inverse")
                    }
                    .padding(16)
                }
                .tint(.purple).foregroundStyle(.white).glassCard()
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}
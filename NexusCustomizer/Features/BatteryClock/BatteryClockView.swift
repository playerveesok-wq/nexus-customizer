import SwiftUI

struct FeatureStub: View {
    let title: String, subtitle: String, icon: String, features: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ScreenHeader(title: title, subtitle: subtitle)
                VStack(spacing: 14) {
                    Image(systemName: icon).font(.system(size: 44))
                        .foregroundStyle(Theme.accent)
                    ForEach(features, id: \.self) { Text("• \($0)").foregroundStyle(.white) }
                }
                .frame(maxWidth: .infinity).padding(28).glassCard()
            }
            .padding(.horizontal, 20)
        }
    }
}

struct BatteryClockView: View {
    var body: some View {
        FeatureStub(title: "Батарея и часы", subtitle: "Иконки, шрифты и цвета",
                    icon: "battery.100percent.bolt",
                    features: ["Каталог иконок батареи", "Превью анимации зарядки", "Шрифты и цвета часов"])
    }
}
import SwiftUI

struct DynamicIslandView: View {
    var body: some View {
        if DeviceCapabilities.hasDynamicIsland {
            FeatureStub(title: "Dynamic Island", subtitle: "Анимации острова",
                        icon: "capsule.fill",
                        features: ["Анимация подключения зарядки", "Live Activities (ActivityKit)"])
        } else {
            ContentUnavailableView("Недоступно", systemImage: "iphone.slash",
                                   description: Text("Нужен iPhone 14 Pro или новее."))
        }
    }
}
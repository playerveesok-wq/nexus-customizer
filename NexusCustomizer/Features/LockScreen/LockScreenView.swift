import SwiftUI

struct LockScreenView: View {
    var body: some View {
        FeatureStub(title: "Экран блокировки", subtitle: "Мокап клавиатуры",
                    icon: "lock.rectangle.stack",
                    features: ["Фон клавиатуры", "Прозрачность кнопок", "Свои звуки нажатия (AVAudioPlayer)"])
    }
}
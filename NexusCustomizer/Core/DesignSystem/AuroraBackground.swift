import SwiftUI

struct AuroraBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.07)

            Group {
                Circle().fill(Color.blue.opacity(0.55))
                    .frame(width: 320).offset(x: -140, y: -280)
                Circle().fill(Color.purple.opacity(0.5))
                    .frame(width: 300).offset(x: 160, y: -60)
                Circle().fill(Color.cyan.opacity(0.35))
                    .frame(width: 260).offset(x: -120, y: 320)
            }
            .blur(radius: 90)
            .drawingGroup()
        }
        .ignoresSafeArea()
    }
}
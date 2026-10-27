import SwiftUI

enum Theme {
    static let accent = LinearGradient(
        colors: [Color(red: 0.36, green: 0.55, blue: 1.0),
                 Color(red: 0.64, green: 0.36, blue: 1.0)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let textSecondary = Color.white.opacity(0.6)
}
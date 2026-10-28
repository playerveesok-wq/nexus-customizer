import SwiftUI
import Observation

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case black = "black"
    case red = "red"
    case orange = "orange"
    case blue = "blue"
    
    var id: String { rawValue }
    
    var titleKey: String {
        switch self {
        case .black: return "theme_black"
        case .red: return "theme_red"
        case .orange: return "theme_orange"
        case .blue: return "theme_blue"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .black: return Color(white: 0.85)
        case .red: return Color(red: 1.0, green: 0.23, blue: 0.19)
        case .orange: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .blue: return Color(red: 0.04, green: 0.52, blue: 1.0)
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .black: return [Color(white: 0.05), Color(white: 0.14), Color.black]
        case .red: return [Color(red: 0.35, green: 0.02, blue: 0.05), Color(red: 0.12, green: 0.01, blue: 0.02), Color.black]
        case .orange: return [Color(red: 0.4, green: 0.18, blue: 0.0), Color(red: 0.15, green: 0.06, blue: 0.0), Color.black]
        case .blue: return [Color(red: 0.0, green: 0.18, blue: 0.42), Color(red: 0.0, green: 0.06, blue: 0.18), Color.black]
        }
    }
}

enum GlassStyle: String, CaseIterable, Identifiable, Codable {
    case ultraThin = "ultraThin"
    case standard = "standard"
    case thick = "thick"
    
    var id: String { rawValue }
    
    var titleKey: String {
        switch self {
        case .ultraThin: return "glass_ultra_thin"
        case .standard: return "glass_standard"
        case .thick: return "glass_thick"
        }
    }
    
    var material: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .standard: return .thinMaterial
        case .thick: return .regularMaterial
        }
    }
    
    var strokeOpacity: Double {
        switch self {
        case .ultraThin: return 0.14
        case .standard: return 0.24
        case .thick: return 0.35
        }
    }
}

@Observable
final class ThemeManager {
    private let themeKey = "nexus.selected.theme"
    private let glassKey = "nexus.selected.glass"
    
    var currentTheme: AppTheme {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey) }
    }
    
    var currentGlassStyle: GlassStyle {
        didSet { UserDefaults.standard.set(currentGlassStyle.rawValue, forKey: glassKey) }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: themeKey) ?? AppTheme.black.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .black
        
        let savedGlass = UserDefaults.standard.string(forKey: glassKey) ?? GlassStyle.standard.rawValue
        self.currentGlassStyle = GlassStyle(rawValue: savedGlass) ?? .standard
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            currentTheme = theme
        }
    }
    
    func setGlassStyle(_ style: GlassStyle) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentGlassStyle = style
        }
    }
}

// MARK: - GlassCard Modifier & GPU Background
struct GlassCardModifier: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.currentGlassStyle.material)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.accentColor.opacity(themeManager.currentGlassStyle.strokeOpacity),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.3), value: themeManager.currentGlassStyle)
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: themeManager.currentTheme)
    }
}

struct NexusAnimatedBackground: View {
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeManager.currentTheme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(themeManager.currentTheme.accentColor.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -110, y: -220)
            
            Circle()
                .fill(themeManager.currentTheme.accentColor.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 85)
                .offset(x: 130, y: 260)
        }
        .ignoresSafeArea()
        .drawingGroup()
        .animation(.easeInOut(duration: 0.5), value: themeManager.currentTheme)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

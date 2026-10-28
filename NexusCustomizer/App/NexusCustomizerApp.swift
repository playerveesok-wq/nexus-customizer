import SwiftUI

@main
struct NexusCustomizerApp: App {
    @State private var themeManager = ThemeManager()
    @State private var fontManager = FontManager()
    @State private var localizationManager = LocalizationManager()
    @State private var iconManager = IconManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(themeManager)
                .environment(fontManager)
                .environment(localizationManager)
                .environment(iconManager)
                .preferredColorScheme(.dark)
        }
    }
}

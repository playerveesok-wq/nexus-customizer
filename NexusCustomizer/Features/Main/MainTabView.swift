import SwiftUI

struct MainTabView: View {
    @Environment(LocalizationManager.self) private var loc
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка 1: Обои (твой старый код)
            WallpapersView(vm: WallpapersViewModel())
                .tabItem {
                    Label("Обои", systemImage: "photo.on.rectangle.angled")
                }
                .tag(0)
            
            // Вкладка 2: Настройки
            SettingsView()
                .tabItem {
                    Label(loc.t("settings_title"), systemImage: "slider.horizontal.3")
                }
                .tag(1)
        }
        .tint(themeManager.currentTheme.accentColor)
    }
}

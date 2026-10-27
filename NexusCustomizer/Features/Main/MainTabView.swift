import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .wallpapers
    @State private var wallpapersVM = WallpapersViewModel()
    @AppStorage("reduceAppAnimations") private var reduceAnimations = false
    @Namespace private var tabNamespace

    var body: some View {
        ZStack {
            AuroraBackground()

            TabView(selection: $selection) {
                ForEach(AppTab.available) { tab in
                    screen(for: tab)
                        .toolbar(.hidden, for: .tabBar)
                        .tag(tab)
                }
            }
            .safeAreaInset(edge: .bottom) { glassTabBar }
        }
        .preferredColorScheme(.dark)
        .transaction { if reduceAnimations { $0.animation = nil } }
    }

    @ViewBuilder
    private func screen(for tab: AppTab) -> some View {
        switch tab {
        case .battery:    BatteryClockView()
        case .wallpapers: WallpapersView(vm: wallpapersVM)
        case .lockScreen: LockScreenView()
        case .island:     DynamicIslandView()
        case .settings:   SettingsView()
        }
    }

    private var glassTabBar: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.available) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.3)) { selection = tab }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon).font(.system(size: 18, weight: .semibold))
                        Text(tab.title).font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(selection == tab ? .white : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if selection == tab {
                            Capsule().fill(Theme.accent.opacity(0.85))
                                .matchedGeometryEffect(id: "pill", in: tabNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .glassCard(cornerRadius: 32)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}
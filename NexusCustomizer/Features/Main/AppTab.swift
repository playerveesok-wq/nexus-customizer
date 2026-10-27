import Foundation

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case battery, wallpapers, lockScreen, island, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .battery:    "Батарея"
        case .wallpapers: "Обои"
        case .lockScreen: "Замок"
        case .island:     "Остров"
        case .settings:   "Ещё"
        }
    }

    var icon: String {
        switch self {
        case .battery:    "battery.100percent.bolt"
        case .wallpapers: "photo.on.rectangle.angled"
        case .lockScreen: "lock.rectangle.stack"
        case .island:     "capsule.fill"
        case .settings:   "slider.horizontal.3"
        }
    }

    static var available: [AppTab] {
        allCases.filter { $0 != .island || DeviceCapabilities.hasDynamicIsland }
    }
}
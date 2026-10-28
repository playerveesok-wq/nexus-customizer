import SwiftUI
import UIKit
import Observation

enum NexusAppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case red = "AppIcon-Red"
    case orange = "AppIcon-Orange"
    case blue = "AppIcon-Blue"
    
    var id: String { rawValue }
    
    var alternateIconName: String? {
        self == .primary ? nil : rawValue
    }
    
    var titleKey: String {
        switch self {
        case .primary: return "icon_default"
        case .red: return "icon_red"
        case .orange: return "icon_orange"
        case .blue: return "icon_blue"
        }
    }
    
    var previewColor: Color {
        switch self {
        case .primary: return Color(white: 0.2)
        case .red: return .red
        case .orange: return .orange
        case .blue: return .blue
        }
    }
}

@Observable
final class IconManager {
    var currentIcon: NexusAppIcon = .primary
    var lastErrorMessage: String?
    
    init() {
        if let currentName = UIApplication.shared.alternateIconName,
           let matched = NexusAppIcon(rawValue: currentName) {
            self.currentIcon = matched
        } else {
            self.currentIcon = .primary
        }
    }
    
    @MainActor
    func setIcon(_ icon: NexusAppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        guard currentIcon != icon else { return }
        
        UIApplication.shared.setAlternateIconName(icon.alternateIconName) { [weak self] error in
            guard let self else { return }
            if let error {
                self.lastErrorMessage = error.localizedDescription
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    self.currentIcon = icon
                }
            }
        }
    }
}

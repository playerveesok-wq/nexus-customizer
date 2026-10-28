import SwiftUI
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case ru = "ru"
    case en = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .ru: return "Русский"
        case .en: return "English"
        }
    }
}

@Observable
final class LocalizationManager {
    private let languageKey = "nexus.selected.language"
    
    var currentLanguage: AppLanguage {
        didSet { UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey) }
    }
    
    private let translations: [AppLanguage: [String: String]] = [
        .ru: [
            "settings_title": "Настройки",
            "section_theme": "Цветовая тема",
            "theme_black": "Черный",
            "theme_red": "Красный",
            "theme_orange": "Оранжевый",
            "theme_blue": "Синий",
            "section_glass": "Стиль стекла",
            "glass_ultra_thin": "Ультра-прозрачное",
            "glass_standard": "Стандартное",
            "glass_thick": "Плотное",
            "section_typography": "Типографика",
            "font_system": "Системный (SF Pro)",
            "font_import_btn": "Импортировать .ttf / .otf",
            "section_language": "Язык интерфейса",
            "section_icons": "Иконка приложения",
            "icon_default": "Стандартная",
            "icon_red": "Красная Матрица",
            "icon_orange": "Солнечный Неон",
            "icon_blue": "Кибер Синий",
            "library_title": "Библиотека IPA",
            "library_import": "Импорт .ipa",
            "library_empty": "Нет загруженных IPA-файлов.\nНажмите «Импорт .ipa», чтобы добавить пакет.",
            "library_importing": "Копирование пакета..."
        ],
        .en: [
            "settings_title": "Settings",
            "section_theme": "Color Theme",
            "theme_black": "Black",
            "theme_red": "Red",
            "theme_orange": "Orange",
            "theme_blue": "Blue",
            "section_glass": "Glass Style",
            "glass_ultra_thin": "Ultra-Thin",
            "glass_standard": "Standard",
            "glass_thick": "Thick",
            "section_typography": "Typography",
            "font_system": "System (SF Pro)",
            "font_import_btn": "Import .ttf / .otf",
            "section_language": "App Language",
            "section_icons": "App Icon",
            "icon_default": "Default",
            "icon_red": "Crimson Matrix",
            "icon_orange": "Solar Neon",
            "icon_blue": "Cyber Blue",
            "library_title": "IPA Library",
            "library_import": "Import .ipa",
            "library_empty": "No IPA packages imported yet.\nTap 'Import .ipa' to add a file.",
            "library_importing": "Importing package..."
        ]
    ]
    
    init() {
        let saved = UserDefaults.standard.string(forKey: languageKey) ?? AppLanguage.ru.rawValue
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .ru
    }
    
    func setLanguage(_ lang: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentLanguage = lang
        }
    }
    
    func t(_ key: String) -> String {
        translations[currentLanguage]?[key] ?? key
    }
}

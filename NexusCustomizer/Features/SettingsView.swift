import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(FontManager.self) private var fontManager
    @Environment(LocalizationManager.self) private var loc
    @Environment(IconManager.self) private var iconManager
    
    @Namespace private var themeNamespace
    @Namespace private var glassNamespace
    @Namespace private var langNamespace
    
    @State private var isFontImporterPresented = false
    
    var body: some View {
        ZStack {
            NexusAnimatedBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    headerView
                    themeSection
                    glassSection
                    languageSection
                    typographySection
                    appIconSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
        }
        .applyNexusTypography(size: 15, relativeTo: .body)
        .fileImporter(
            isPresented: $isFontImporterPresented,
            allowedContentTypes: [.font],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let firstURL = urls.first {
                Task { try? await fontManager.importFont(from: firstURL) }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text(loc.t("settings_title"))
                .applyNexusTypography(size: 32, relativeTo: .largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Spacer()
        }
    }
    
    // MARK: - 1. Theme Picker
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.t("section_theme"))
                .applyNexusTypography(size: 13, relativeTo: .caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
            
            HStack(spacing: 10) {
                ForEach(AppTheme.allCases) { theme in
                    let isSelected = themeManager.currentTheme == theme
                    Button {
                        themeManager.setTheme(theme)
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 26, height: 26)
                                .shadow(color: theme.accentColor.opacity(0.6), radius: isSelected ? 8 : 0)
                            
                            Text(loc.t(theme.titleKey))
                                .applyNexusTypography(size: 12, relativeTo: .caption)
                                .fontWeight(isSelected ? .bold : .medium)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(theme.accentColor.opacity(0.22))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(theme.accentColor, lineWidth: 1.5)
                                    )
                                    .matchedGeometryEffect(id: "THEME_SELECTOR", in: themeNamespace)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - 2. Glassmorphism Style Picker
    private var glassSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.t("section_glass"))
                .applyNexusTypography(size: 13, relativeTo: .caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
            
            HStack(spacing: 8) {
                ForEach(GlassStyle.allCases) { style in
                    let isSelected = themeManager.currentGlassStyle == style
                    Button {
                        themeManager.setGlassStyle(style)
                    } label: {
                        Text(loc.t(style.titleKey))
                            .applyNexusTypography(size: 13, relativeTo: .subheadline)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(themeManager.currentTheme.accentColor.opacity(0.28))
                                        .matchedGeometryEffect(id: "GLASS_SELECTOR", in: glassNamespace)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - 3. In-App Language
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.t("section_language"))
                .applyNexusTypography(size: 13, relativeTo: .caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
            
            HStack(spacing: 10) {
                ForEach(AppLanguage.allCases) { lang in
                    let isSelected = loc.currentLanguage == lang
                    Button {
                        loc.setLanguage(lang)
                    } label: {
                        Text(lang.displayName)
                            .applyNexusTypography(size: 14, relativeTo: .body)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(themeManager.currentTheme.accentColor.opacity(0.28))
                                        .matchedGeometryEffect(id: "LANG_SELECTOR", in: langNamespace)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - 4. Typography & Custom Fonts
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.t("section_typography"))
                    .applyNexusTypography(size: 13, relativeTo: .caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                
                Spacer()
                
                Button {
                    isFontImporterPresented = true
                } label: {
                    Label(loc.t("font_import_btn"), systemImage: "plus.circle.fill")
                        .applyNexusTypography(size: 13, relativeTo: .caption)
                        .foregroundStyle(themeManager.currentTheme.accentColor)
                }
            }
            
            VStack(spacing: 8) {
                fontRow(
                    title: loc.t("font_system"),
                    isSelected: fontManager.selectedPostScriptName == nil
                ) {
                    fontManager.selectSystemFont()
                }
                
                ForEach(fontManager.customFonts) { item in
                    fontRow(
                        title: item.displayName,
                        isSelected: fontManager.selectedPostScriptName == item.postScriptName
                    ) {
                        fontManager.selectFont(item)
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private func fontRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(themeManager.currentTheme.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.03))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 5. Alternate Icons
    private var appIconSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.t("section_icons"))
                .applyNexusTypography(size: 13, relativeTo: .caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
            
            VStack(spacing: 10) {
              ForEach(NexusAppIcon.allCases, id: \.self) { icon in
                    let isSelected = iconManager.currentIcon == icon
                    Button {
                           Task { @MainActor in
                            iconManager.setIcon(icon)
                        }
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(icon.previewColor.gradient)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.white)
                                )
                            
                            Text(loc.t(icon.titleKey))
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(themeManager.currentTheme.accentColor)
                                    .font(.title3)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(isSelected ? 0.12 : 0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}

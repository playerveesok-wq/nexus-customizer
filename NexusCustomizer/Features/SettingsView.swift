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
                    Button(action: {
                        Task { @MainActor in
                            iconManager.setIcon(icon)
                        }
                    }) {
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

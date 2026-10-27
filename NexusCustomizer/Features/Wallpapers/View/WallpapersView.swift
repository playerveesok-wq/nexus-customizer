import SwiftUI

struct WallpapersView: View {
    @Bindable var vm: WallpapersViewModel
    @State private var showPicker = false
    @State private var previewItem: WallpaperItem?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ScreenHeader(title: "Обои", subtitle: "Фото и GIF из вашей галереи")
                heroPreview
                addButton
                grid
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showPicker) {
            PhotoPicker(selectionLimit: 10) { results in
                showPicker = false
                Task { await vm.importPicked(results) }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(item: $previewItem) { item in
            WallpaperPreviewView(item: item, isSelected: vm.selectedID == item.id) {
                vm.select(item.id)
            }
        }
        .alert("Ошибка", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } })
        ) { Button("OK", role: .cancel) {} } message: { Text(vm.errorMessage ?? "") }
    }

    private var heroPreview: some View {
        let shape = RoundedRectangle(cornerRadius: 44, style: .continuous)
        return ZStack {
            if let item = vm.selectedItem {
                StoredImageView(item: item, maxPixel: 900)
            } else {
                LinearGradient(colors: [.indigo.opacity(0.5), .black], startPoint: .top, endPoint: .bottom)
                Text("Выберите обои").font(.callout).foregroundStyle(Theme.textSecondary)
            }

            VStack(spacing: 2) {
                Text("Вторник, 12 марта").font(.system(size: 14, weight: .medium))
                Text("9:41").font(.system(size: 64, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.4), radius: 8)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 36)
        }
        .frame(width: 220, height: 220 * 19.5 / 9)
        .clipShape(shape)
        .overlay(shape.strokeBorder(.white.opacity(0.25), lineWidth: 3))
        .shadow(color: .purple.opacity(0.35), radius: 30, y: 16)
        .animation(.smooth, value: vm.selectedID)
    }

    private var addButton: some View {
        Button { showPicker = true } label: {
            HStack(spacing: 10) {
                if vm.isImporting { ProgressView().tint(.white) }
                else { Image(systemName: "plus.circle.fill") }
                Text(vm.isImporting ? "Импорт…" : "Добавить из галереи").fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(Theme.accent, in: Capsule())
            .shadow(color: .purple.opacity(0.4), radius: 14, y: 6)
        }
        .disabled(vm.isImporting)
    }

    @ViewBuilder
    private var grid: some View {
        if vm.items.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "photo.stack").font(.largeTitle)
                Text("Пока пусто").font(.headline)
                Text("Добавленные обои сохранятся в приложении").font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 32)
            .glassCard()
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.items) { item in cell(for: item) }
            }
        }
    }

    private func cell(for item: WallpaperItem) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return Color.clear
            .aspectRatio(9.0 / 16.0, contentMode: .fit)
            .overlay { StoredImageView(item: item, maxPixel: 300) }
            .clipShape(shape)
            .overlay(alignment: .topTrailing) {
                if item.isAnimated {
                    Text("GIF").font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule()).padding(6)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if vm.selectedID == item.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, .blue).font(.title3).padding(6)
                }
            }
            .overlay(shape.strokeBorder(vm.selectedID == item.id ? Color.white.opacity(0.9) : .white.opacity(0.12), lineWidth: vm.selectedID == item.id ? 2 : 1))
            .contentShape(shape)
            .onTapGesture { previewItem = item }
            .contextMenu {
                Button("Выбрать", systemImage: "checkmark.circle") { vm.select(item.id) }
                Button("Удалить", systemImage: "trash", role: .destructive) { Task { await vm.delete(item) } }
            }
    }
}
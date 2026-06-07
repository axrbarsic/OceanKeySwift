import SwiftUI

struct SettingsScreen: View {
    @Bindable var workSession: WorkSessionStore

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SpriteKitEffectView(.matrixRain)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    developerSection
                    storageSection
                    migrationSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .black))
                    .frame(width: 48, height: 48)
                    .foregroundStyle(OceanKeyTheme.secondaryText)
                    .background(OceanKeyTheme.surface.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text("Настройки")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
    }

    private var developerSection: some View {
        SettingsPanel(title: "Разработчик") {
            SettingsInfoRow(title: "Версия", value: AppBuildInfo.versionLabel, systemName: "number")
            SettingsInfoRow(title: "Движок", value: "SpriteKit + SwiftUI", systemName: "sparkles")
            SettingsInfoRow(title: "Цель", value: "Физический iPhone", systemName: "iphone")
        }
    }

    private var storageSection: some View {
        SettingsPanel(title: "Локальные данные") {
            SettingsInfoRow(title: "Ячеек", value: "\(workSession.counts.total)", systemName: "rectangle.grid.1x2")
            SettingsInfoRow(title: "Готово", value: "\(workSession.counts.completed)", systemName: "checkmark.circle.fill")
            SettingsInfoRow(title: "Хранилище", value: persistenceStatus, systemName: "externaldrive.fill")
        }
    }

    private var migrationSection: some View {
        SettingsPanel(title: "Перенос") {
            Text("Эта Swift-версия пока идёт отдельной веткой. Flutter-приложение остаётся эталоном поведения до полной готовности нативной версии.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(OceanKeyTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var persistenceStatus: String {
        if let error = workSession.lastPersistenceError {
            return "Ошибка: \(error.localizedDescription)"
        }
        return "Активно"
    }
}

private struct SettingsPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                content
            }
            .padding(14)
            .background(OceanKeyTheme.surface.opacity(0.84))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(OceanKeyTheme.accent.opacity(0.22), lineWidth: 1)
            }
        }
    }
}

private struct SettingsInfoRow: View {
    let title: String
    let value: String
    let systemName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .black))
                .frame(width: 34, height: 34)
                .foregroundStyle(OceanKeyTheme.accent)
                .background(OceanKeyTheme.accent.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(OceanKeyTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(minHeight: 48)
    }
}

#Preview {
    SettingsScreen(workSession: .preview())
        .preferredColorScheme(.dark)
}


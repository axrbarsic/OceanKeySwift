import PhotosUI
import SwiftUI

struct SettingsBackgroundSection: View {
    @Bindable var appSettings: AppSettingsStore
    @Bindable var aiVisualPresetStore: AIVisualPresetStore

    @Environment(\.interactionFeedback) private var feedback
    @State private var selectedBackgroundVideoItem: PhotosPickerItem?

    var body: some View {
        SettingsPanel(
            title: "Фон приложения",
            subtitle: "Matrix Rain, телевизионный шум или локальное видео как живая заставка основного экрана."
        ) {
            Picker("Заставка", selection: $appSettings.appBackgroundMode) {
                ForEach(visibleBackgroundModes) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appSettings.appBackgroundMode) { _, _ in
                feedback.confirm()
            }

            SettingsInfoRow(
                title: "Заставка",
                value: appSettings.appBackgroundMode.description,
                systemName: "grid",
                subtitle: backgroundModeSubtitle
            )
            if appSettings.appBackgroundMode == .matrixRain {
                matrixControls
            }
            // AI-generated Matrix presets are intentionally hidden from Settings for now.
            // if appSettings.appBackgroundMode == .aiGenerated {
            //     aiGeneratedControls
            // }
            if appSettings.appBackgroundMode == .tvStaticNoise {
                tvStaticControls
            }
            if appSettings.appBackgroundMode == .video {
                videoControls
            }
        }
        .onAppear(perform: hideHiddenAIBackgroundIfNeeded)
    }

    private var visibleBackgroundModes: [AppBackgroundMode] {
        AppBackgroundMode.allCases.filter { $0 != .aiGenerated }
    }

    private var matrixControls: some View {
        SettingsSliderRow(
            title: "Скорость",
            valueLabel: "\(String(format: "%.2f", appSettings.matrixSpeed))x",
            systemName: "speedometer",
            range: 0.08...3.0,
            defaultValue: MatrixRainConfiguration.default.speed,
            value: $appSettings.matrixSpeed
        )
    }

    private var backgroundModeSubtitle: String {
        switch appSettings.appBackgroundMode {
        case .off:
            "Фон отключён, основной экран остаётся чёрным."
        case .matrixRain:
            "Matrix Rain как основной живой фон."
        case .aiGenerated:
            "AI Matrix-пресеты временно скрыты из настроек."
        case .tvStaticNoise:
            "ShaderKit Dynamic Gray Noise: аналоговый телевизионный снег как основной фон."
        case .video:
            "Видео хранится только локально на устройстве."
        }
    }

    private var aiGeneratedControls: some View {
        let matrixPresets = aiVisualPresetStore.presets.filter { $0.kind == .matrixCodeRain }

        return VStack(alignment: .leading, spacing: 12) {
            SettingsInfoRow(
                title: activeAIBackgroundPreset?.title ?? "AI Wallpaper",
                value: activeAIBackgroundPreset == nil ? (matrixPresets.isEmpty ? "Нет" : "Выбери") : "Включён",
                systemName: "sparkles",
                subtitle: activeAIBackgroundPreset?.summary
                    ?? (matrixPresets.isEmpty
                        ? "Сначала сгенерируй и сохрани Matrix Code Rain пресет в DeepSeek Lab."
                        : "Выбери один из сохранённых Matrix-пресетов.")
            )

            ForEach(matrixPresets) { preset in
                AIBackgroundPresetActivationRow(
                    preset: preset,
                    isActive: preset.id == appSettings.activeAIVisualPresetID,
                    onActivate: { activateAIBackgroundPreset(preset) }
                )
            }
        }
    }

    private var activeAIBackgroundPreset: AIVisualPreset? {
        guard let activeID = appSettings.activeAIVisualPresetID else { return nil }
        return aiVisualPresetStore.presets.first { $0.id == activeID && $0.kind == .matrixCodeRain }
    }

    private var videoControls: some View {
        let videoStatus = appSettings.backgroundVideoRelativePath == nil ? "Выбрать" : "Выбрано"

        return VStack(alignment: .leading, spacing: 12) {
            PhotosPicker(
                selection: $selectedBackgroundVideoItem,
                matching: .videos,
                photoLibrary: .shared()
            ) {
                BackgroundVideoPickerLabel(videoStatus: videoStatus)
            }
            .buttonStyle(.plain)
            .onChange(of: selectedBackgroundVideoItem) { _, item in
                guard let item else { return }
                Task { await importBackgroundVideo(item) }
            }

            SettingsSliderRow(
                title: "Матовость",
                valueLabel: "\(Int((appSettings.backgroundVideoBlur * 100).rounded()))%",
                systemName: "aqi.medium",
                range: 0...1,
                defaultValue: 0.28,
                value: $appSettings.backgroundVideoBlur
            )
            SettingsSliderRow(
                title: "Яркость",
                valueLabel: "\(Int((appSettings.backgroundVideoBrightness * 100).rounded()))%",
                systemName: "sun.max.fill",
                range: -0.85...0.85,
                defaultValue: 0.08,
                value: $appSettings.backgroundVideoBrightness
            )
            SettingsSliderRow(
                title: "Зелёный",
                valueLabel: "\(Int((appSettings.backgroundVideoGreenTint * 100).rounded()))%",
                systemName: "leaf.fill",
                range: 0...1,
                defaultValue: 0.34,
                value: $appSettings.backgroundVideoGreenTint
            )
            SettingsSliderRow(
                title: "Сетка",
                valueLabel: "\(Int((appSettings.backgroundVideoGridIntensity * 100).rounded()))%",
                systemName: "squareshape.split.3x3",
                range: 0...1,
                defaultValue: 0,
                value: $appSettings.backgroundVideoGridIntensity
            )
        }
    }

    private var tvStaticControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                SettingsInfoRow(
                    title: "Вариант шума",
                    value: appSettings.tvStaticVariant.title,
                    systemName: "tv.fill",
                    subtitle: appSettings.tvStaticVariant.description
                )

                Picker("Вариант шума", selection: $appSettings.tvStaticVariant) {
                    ForEach(TVStaticNoiseVariant.allCases) { variant in
                        Text(variant.title).tag(variant)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: appSettings.tvStaticVariant) { _, _ in
                    feedback.confirm()
                }
            }

            SettingsSliderRow(
                title: "Яркость",
                valueLabel: "\(Int((appSettings.tvStaticBrightness * 100).rounded()))%",
                systemName: "sun.max.fill",
                range: -1...1,
                defaultValue: TVStaticNoiseConfiguration.default.brightness,
                value: $appSettings.tvStaticBrightness
            )
            SettingsSliderRow(
                title: "Зелёный",
                valueLabel: "\(Int((appSettings.tvStaticGreenTint * 100).rounded()))%",
                systemName: "leaf.fill",
                range: 0...1,
                defaultValue: TVStaticNoiseConfiguration.default.greenTint,
                value: $appSettings.tvStaticGreenTint
            )
        }
    }

    private func activateAIBackgroundPreset(_ preset: AIVisualPreset) {
        feedback.confirm()
        appSettings.activeAIVisualPresetID = preset.id
        appSettings.appBackgroundMode = .aiGenerated
    }

    private func hideHiddenAIBackgroundIfNeeded() {
        guard appSettings.appBackgroundMode == .aiGenerated else { return }
        appSettings.appBackgroundMode = .matrixRain
        appSettings.activeAIVisualPresetID = nil
    }

    @MainActor
    private func importBackgroundVideo(_ item: PhotosPickerItem) async {
        do {
            guard let pickedVideo = try await item.loadTransferable(type: PickedBackgroundVideo.self) else { return }
            let relativePath = try BackgroundVideoFileStore().saveVideo(from: pickedVideo.url)
            appSettings.backgroundVideoRelativePath = relativePath
            appSettings.appBackgroundMode = .video
            feedback.confirm()
        } catch {
            feedback.holdWarning()
        }
    }
}

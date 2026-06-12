import SwiftUI

struct AppRootView: View {
    @Bindable var workSession: WorkSessionStore
    @Bindable var appSettings: AppSettingsStore
    @Bindable var aiVisualPresetStore: AIVisualPresetStore
    @Bindable var performanceTelemetry: PerformanceTelemetryStore
    let isWorkSessionLoaded: Bool
    let interactionFeedbackService: InteractionFeedbackService

    var body: some View {
        NavigationStack {
            if !isWorkSessionLoaded {
                AppStartupLoadingView()
            } else if workSession.selection.workdayLocked {
                SummaryScreen(
                    workSession: workSession,
                    appSettings: appSettings,
                    aiVisualPresetStore: aiVisualPresetStore,
                    performanceTelemetry: performanceTelemetry
                )
            } else {
                WorkSetupScreen(
                    workSession: workSession,
                    appSettings: appSettings,
                    aiVisualPresetStore: aiVisualPresetStore,
                    performanceTelemetry: performanceTelemetry
                )
            }
        }
        .environment(\.appBackgroundMode, visibleBackgroundMode)
        .environment(\.appBackgroundVideoURL, appSettings.backgroundVideoURL)
        .environment(\.appBackgroundVideoBlur, appSettings.backgroundVideoBlur)
        .environment(\.appBackgroundVideoBrightness, appSettings.backgroundVideoBrightness)
        .environment(\.appBackgroundVideoGreenTint, appSettings.backgroundVideoGreenTint)
        .environment(\.appBackgroundVideoGridIntensity, appSettings.backgroundVideoGridIntensity)
        .environment(\.matrixRainConfiguration, appSettings.matrixConfiguration)
        .environment(\.tvStaticNoiseConfiguration, appSettings.tvStaticNoiseConfiguration)
        .environment(\.activeAIVisualPreset, activeAIVisualPreset)
        .environment(\.experimentalCellPhysicsEnabled, appSettings.developerCellPhysicsEnabled)
        .environment(\.experimentalCellSpringIntensity, appSettings.developerCellSpringIntensity)
        .environment(\.experimentalCellSpringSpeed, appSettings.developerCellSpringSpeed)
        .environment(\.experimentalVIPJellyEnabled, appSettings.developerVIPJellyEnabled)
        .environment(\.experimentalVIPJellySpeed, appSettings.developerVIPJellySpeed)
        .environment(
            \.interactionFeedback,
            .live(interactionFeedbackService)
        )
        .preferredColorScheme(.dark)
    }

    private var activeAIVisualPreset: AIVisualPreset? {
        guard let activeID = appSettings.activeAIVisualPresetID else { return nil }
        return aiVisualPresetStore.presets.first { $0.id == activeID && $0.kind == .matrixCodeRain }
    }

    private var visibleBackgroundMode: AppBackgroundMode {
        appSettings.appBackgroundMode == .aiGenerated ? .matrixRain : appSettings.appBackgroundMode
    }
}

private struct AppStartupLoadingView: View {
    var body: some View {
        ZStack {
            AppBackgroundView()

            ProgressView()
                .tint(OceanKeyTheme.accent)
                .scaleEffect(1.08)
        }
        .accessibilityLabel("Загрузка смены")
    }
}

import Foundation
import Testing
@testable import OceanKeySwift

@MainActor
@Test
func aiVisualPresetStoreSavesAndReloadsPreset() throws {
    let store = try AIVisualPresetStore(inMemory: true)
    let draft = AIVisualPresetDraft(
        title: "Кодовый дождь",
        summary: "Swift-код падает как зелёная матрица.",
        kind: .matrixCodeRain,
        payload: .matrixDefault
    )

    store.save(draft: draft, modelTier: .pro, prompt: "swift code rain")

    #expect(store.presets.count == 1)
    #expect(store.presets.first?.title == "Кодовый дождь")
    #expect(store.presets.first?.kind == .matrixCodeRain)
    #expect(store.presets.first?.modelTier == .pro)
    #expect(store.presets.first?.payload == .matrixDefault)
}

@MainActor
@Test
func aiVisualPresetStoreReportsStorageModeExplicitly() throws {
    let memoryStore = try AIVisualPresetStore(inMemory: true)
    #expect(memoryStore.storageMode == .memoryOnly)
    #expect(memoryStore.storageMode.isAppleSynced == false)

    let fallbackStore = try AIVisualPresetStore(localFallbackReason: "Provisioning profile is missing iCloud.")
    #expect(fallbackStore.storageMode.isAppleSynced == false)
    #expect(fallbackStore.storageMode.statusTitle == "Apple sync недоступен")
}

@Test
func deepSeekPresetDecodeClampsPayloadAndKeepsRequestedKind() throws {
    let content = """
    {
      "title": "VIP",
      "summary": "Пульсирующий VIP эффект.",
      "kind": "matrixCodeRain",
      "payload": {
        "palette": "status_adaptive",
        "speed": 99,
        "glow": -1,
        "blur": 4,
        "density": 2,
        "glyphSource": "none",
        "motion": "organic_status_pulse",
        "seed": 42
      }
    }
    """

    let draft = try DeepSeekClient.decodePreset(content, fallbackKind: .vipEffect)

    #expect(draft.kind == .vipEffect)
    #expect(draft.payload.speed == 3.0)
    #expect(draft.payload.glow == 0)
    #expect(draft.payload.blur == 1)
    #expect(draft.payload.density == 1)
}

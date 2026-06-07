enum VoiceCapturePhase: Equatable {
    case idle
    case requestingPermission
    case starting
    case recording
    case finishing
    case failed(String)

    var isRecording: Bool {
        self == .recording
    }

    var canToggle: Bool {
        switch self {
        case .idle, .recording, .failed:
            true
        case .requestingPermission, .starting, .finishing:
            false
        }
    }
}

@MainActor
protocol VoiceTranscriptionServicing: AnyObject {
    typealias TranscriptHandler = @MainActor (String) -> Void
    typealias StatusHandler = @MainActor (String) -> Void
    typealias PhaseHandler = @MainActor (VoiceCapturePhase) -> Void

    func start(
        baseText: String,
        onTranscript: @escaping TranscriptHandler,
        onStatus: @escaping StatusHandler,
        onPhase: @escaping PhaseHandler
    ) async
    func stop()
    func cancel()
}

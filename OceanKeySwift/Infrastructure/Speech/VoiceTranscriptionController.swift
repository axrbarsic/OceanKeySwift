import AVFoundation
import Observation
import Speech

private enum VoiceTranscriptionError: LocalizedError {
    case invalidInputFormat

    var errorDescription: String? {
        switch self {
        case .invalidInputFormat:
            "Микрофон не отдал аудио-формат"
        }
    }
}

private enum VoiceCaptureState {
    case idle
    case starting
    case recording
    case stopping
}

private func requestSpeechRecognitionPermission() async -> Bool {
    await withCheckedContinuation { continuation in
        SFSpeechRecognizer.requestAuthorization { status in
            continuation.resume(returning: status == .authorized)
        }
    }
}

private func requestMicrophonePermission() async -> Bool {
    await withCheckedContinuation { continuation in
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
    }
}

@MainActor
@Observable
final class VoiceTranscriptionController {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var baseText = ""
    private var onTranscript: ((String) -> Void)?
    private var hasInstalledTap = false
    private var captureState = VoiceCaptureState.idle
    private var activeSessionID: UUID?

    private(set) var isRecording = false
    private(set) var statusText = "Готово к записи"

    func toggle(transcript: String, onTranscript: @escaping (String) -> Void) {
        if isRecording {
            stop()
        } else {
            guard captureState == .idle else { return }
            Task {
                await start(transcript: transcript, onTranscript: onTranscript)
            }
        }
    }

    func stop() {
        guard captureState != .idle else { return }
        finishRecording(status: "Расшифровка сохранена", cancelTask: false)
    }

    private func start(transcript: String, onTranscript: @escaping (String) -> Void) async {
        guard captureState == .idle else { return }
        let sessionID = UUID()
        activeSessionID = sessionID
        captureState = .starting
        isRecording = true

        guard await requestPermissions() else { return }
        guard activeSessionID == sessionID, captureState == .starting else { return }
        guard let recognizer else {
            finishRecording(status: "Русское распознавание речи недоступно", cancelTask: true)
            return
        }
        guard recognizer.isAvailable else {
            finishRecording(status: "Распознавание речи недоступно", cancelTask: true)
            return
        }

        stopExistingTask()
        guard activeSessionID == sessionID else { return }
        baseText = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        self.onTranscript = onTranscript

        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        if #available(iOS 16.0, *) {
            request.addsPunctuation = true
        }
        audioEngine = engine
        recognitionRequest = request

        do {
            try configureRecordingSession()
            try installAudioTap(on: engine, request: request)
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    self?.handleRecognition(result: result, error: error)
                }
            }
            engine.prepare()
            try engine.start()
            guard activeSessionID == sessionID, captureState == .starting else {
                finishRecording(status: "Расшифровка остановлена", cancelTask: true)
                return
            }
            captureState = .recording
            statusText = "Слушаю..."
        } catch {
            statusText = "Ошибка микрофона: \(error.localizedDescription)"
            finishRecording(status: statusText, cancelTask: true)
        }
    }

    private func requestPermissions() async -> Bool {
        statusText = "Проверяю доступ..."
        let speechAllowed = await requestSpeechRecognitionPermission()
        guard speechAllowed else {
            finishRecording(status: "Нет доступа к распознаванию речи", cancelTask: true)
            return false
        }

        let micAllowed = await requestMicrophonePermission()
        guard micAllowed else {
            finishRecording(status: "Нет доступа к микрофону", cancelTask: true)
            return false
        }
        return true
    }

    private func configureRecordingSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.allowBluetoothHFP, .defaultToSpeaker, .mixWithOthers]
        )
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func restoreInteractionAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            statusText = "Запись остановлена"
        }
    }

    private func installAudioTap(on engine: AVAudioEngine, request: SFSpeechAudioBufferRecognitionRequest) throws {
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw VoiceTranscriptionError.invalidInputFormat
        }
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format) { buffer, _ in
            request.append(buffer)
        }
        hasInstalledTap = true
    }

    private func handleRecognition(result: SFSpeechRecognitionResult?, error: Error?) {
        guard captureState == .recording || captureState == .starting else { return }
        if let result {
            let recognized = result.bestTranscription.formattedString
            let combined = [baseText, recognized]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
            onTranscript?(combined)
            statusText = result.isFinal ? "Готово" : "Слушаю..."
        }
        if let error, isRecording {
            finishRecording(status: "Распознавание: \(error.localizedDescription)", cancelTask: true)
        }
    }

    private func stopExistingTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        stopAudioEngine()
    }

    private func finishRecording(status: String, cancelTask: Bool) {
        captureState = .stopping
        let request = recognitionRequest
        let task = recognitionTask
        isRecording = false
        statusText = status
        stopAudioEngine()
        request?.endAudio()
        if cancelTask {
            task?.cancel()
        }
        recognitionTask = nil
        recognitionRequest = nil
        activeSessionID = nil
        captureState = .idle
        restoreInteractionAudioSession()
    }

    private func stopAudioEngine() {
        guard let engine = audioEngine else { return }
        if engine.isRunning {
            engine.stop()
        }
        if hasInstalledTap {
            engine.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }
        audioEngine = nil
    }
}

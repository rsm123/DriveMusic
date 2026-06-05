// AudioRecorderService.swift
// DriveMusic AI
//
// Wraps AVAudioRecorder in a Swift actor to guarantee thread-safe access.
// Records audio as .m4a (AAC, 44.1 kHz, mono) for Whisper compatibility.

import AVFoundation
import Foundation

// MARK: - Errors

/// Errors that can be thrown by AudioRecorderService.
enum AudioRecorderError: LocalizedError {
    case permissionDenied
    case setupFailed(underlying: Error)
    case recordingFailed
    case noFileProduced

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access was denied. Please enable it in Settings → Privacy → Microphone."
        case .setupFailed(let error):
            return "Failed to set up the audio recorder: \(error.localizedDescription)"
        case .recordingFailed:
            return "Recording failed to start. Please try again."
        case .noFileProduced:
            return "No audio was captured. Please try again."
        }
    }
}

// MARK: - Service

/// Thread-safe audio recording service backed by AVAudioRecorder.
///
/// Usage:
/// ```swift
/// let service = AudioRecorderService()
/// try await service.startRecording()
/// // … user taps stop or 10 s elapses …
/// let url = await service.stopRecording()
/// ```
actor AudioRecorderService: NSObject {

    // MARK: - Configuration

    /// Maximum recording duration in seconds. Auto-stop fires when reached.
    static let maxDuration: TimeInterval = 10

    // MARK: - Private State

    private var recorder: AVAudioRecorder?
    private var outputURL: URL?
    private var autoStopTask: Task<Void, Never>?

    // MARK: - Public API

    /// Requests microphone permission.
    /// - Throws: `AudioRecorderError.permissionDenied` if the user has denied access.
    func requestPermission() async throws {
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { throw AudioRecorderError.permissionDenied }
    }

    /// Starts recording audio to a temporary `.m4a` file.
    ///
    /// - Throws: `AudioRecorderError` if permission is denied or AVAudioRecorder setup fails.
    func startRecording() async throws {
        // Ensure we have permission before touching the recorder.
        guard await AVAudioApplication.requestRecordPermission() else {
            throw AudioRecorderError.permissionDenied
        }

        // Configure the shared audio session for recording.
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        // Create a unique temp file path each time.
        let fileName = "drivemusic_\(UUID().uuidString).m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        outputURL = url

        // High-quality AAC settings — compatible with Whisper.
        let settings: [String: Any] = [
            AVFormatIDKey:            Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:          44_100,
            AVNumberOfChannelsKey:    1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.delegate = self
            rec.isMeteringEnabled = false // Enable if you add a waveform visualiser later.
            guard rec.record() else { throw AudioRecorderError.recordingFailed }
            self.recorder = rec
        } catch let error as AudioRecorderError {
            throw error
        } catch {
            throw AudioRecorderError.setupFailed(underlying: error)
        }

        // Schedule auto-stop after maxDuration.
        autoStopTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(AudioRecorderService.maxDuration))
            guard !Task.isCancelled else { return }
            await self?.stopRecorderInternal()
        }
    }

    /// Stops recording and returns the URL of the recorded file.
    ///
    /// - Returns: The local file URL, or `nil` if nothing was recorded.
    func stopRecording() async -> URL? {
        autoStopTask?.cancel()
        autoStopTask = nil
        return await stopRecorderInternal()
    }

    // MARK: - Private

    @discardableResult
    private func stopRecorderInternal() async -> URL? {
        recorder?.stop()
        recorder = nil

        // Deactivate audio session so other audio (e.g. music) can resume.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        guard let url = outputURL, FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return url
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorderService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        // In a production app, surface this to the ViewModel via a continuation or callback.
        print("⚠️ AudioRecorder encode error: \(error?.localizedDescription ?? "unknown")")
    }
}

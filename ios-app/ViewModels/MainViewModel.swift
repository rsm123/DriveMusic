// MainViewModel.swift
// DriveMusic AI
//
// Orchestrates AudioRecorderService and OpenAIService.
// Drives UI state via @Observable so only affected views re-render.

import Foundation
import Observation

@Observable
@MainActor
final class MainViewModel {

    // MARK: - Published State

    /// The current state of the record → transcribe pipeline.
    private(set) var appState: AppState = .idle

    // MARK: - Dependencies

    private let audioService: AudioRecorderService
    private let openAIService: OpenAIService

    // MARK: - Private

    /// Tracks the elapsed recording seconds for the UI counter.
    private var elapsedTask: Task<Void, Never>?
    /// Holds the active recording → transcribe pipeline task so it can be cancelled.
    private var pipelineTask: Task<Void, Never>?

    // MARK: - Init

    /// - Parameters:
    ///   - audioService: Injected audio recorder. Defaults to a fresh instance.
    ///   - openAIService: Injected OpenAI client. Requires a valid API key.
    init(
        audioService: AudioRecorderService = AudioRecorderService(),
        openAIService: OpenAIService
    ) {
        self.audioService = audioService
        self.openAIService = openAIService
    }

    // MARK: - Public Actions

    /// Called when the user taps the microphone button.
    func microphoneButtonTapped() {
        if appState.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    // MARK: - Private — Recording

    private func startRecording() {
        pipelineTask = Task {
            await runPipeline()
        }
    }

    private func stopRecording() {
        // Cancel the elapsed counter and the auto-stop in the pipeline.
        elapsedTask?.cancel()
        elapsedTask = nil
        // Signal the pipeline to proceed to upload by cancelling the wait.
        pipelineTask?.cancel()
        pipelineTask = nil

        // Kick off the stop → upload → transcribe chain.
        Task {
            await finaliseRecording()
        }
    }

    // MARK: - Private — Pipeline

    /// Full pipeline: permission → record → upload → transcribe → display.
    private func runPipeline() async {
        // 1. Permission
        do {
            try await audioService.requestPermission()
        } catch {
            appState = .error(message: error.localizedDescription)
            return
        }

        // 2. Start recording
        do {
            try await audioService.startRecording()
        } catch {
            appState = .error(message: error.localizedDescription)
            return
        }

        // 3. Show recording state and tick elapsed seconds.
        var elapsed = 0
        appState = .recording(elapsed: elapsed)
        elapsedTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                elapsed += 1
                appState = .recording(elapsed: elapsed)

                // Auto-advance after max duration.
                if elapsed >= Int(AudioRecorderService.maxDuration) {
                    break
                }
            }
            // Auto-stop path: stop recorder and proceed.
            if !Task.isCancelled {
                await finaliseRecording()
            }
        }

        // Wait until either: the user taps stop (pipelineTask cancelled)
        // or the elapsed ticker above handles it. We park here.
        // (The elapsed task drives finalization; we just hold the pipeline open.)
        await withTaskCancellationHandler {
            // Park — finalization is driven by elapsedTask or stopRecording().
            try? await Task.sleep(for: .seconds(AudioRecorderService.maxDuration + 5))
        } onCancel: {
            // User tapped stop — finaliseRecording() is called by stopRecording().
        }
    }

    /// Stops the recorder and runs the upload + transcription stages.
    private func finaliseRecording() async {
        elapsedTask?.cancel()
        elapsedTask = nil

        // Stop the recorder and get the file URL.
        let fileURL = await audioService.stopRecording()
        guard let fileURL else {
            appState = .error(message: "No audio was captured. Please try again.")
            return
        }

        // 4. Uploading
        appState = .uploading

        // 5. Transcribing
        appState = .transcribing

        do {
            let transcript = try await openAIService.transcribe(audioURL: fileURL)
            appState = .completed(transcript: transcript)
        } catch {
            appState = .error(message: error.localizedDescription)
        }

        // Clean up the temp file.
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Convenience

    /// Resets the UI back to the idle state.
    func reset() {
        pipelineTask?.cancel()
        elapsedTask?.cancel()
        pipelineTask = nil
        elapsedTask = nil
        appState = .idle
    }
}

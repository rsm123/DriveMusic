// AppState.swift
// DriveMusic AI
//
// Defines the recording state machine used by the ViewModel and View.

import Foundation

/// Represents every state the app can be in during the record → transcribe pipeline.
enum AppState: Equatable {

    /// Waiting for the user to tap the microphone button.
    case idle

    /// Actively recording audio. `elapsed` is the number of seconds recorded so far.
    case recording(elapsed: Int)

    /// Recording finished; uploading the audio file to OpenAI.
    case uploading

    /// Audio uploaded; awaiting the transcript from OpenAI.
    case transcribing

    /// Pipeline completed successfully. `transcript` is the full text returned by Whisper.
    case completed(transcript: String)

    /// A failure occurred at any stage. `message` is a human-readable description.
    case error(message: String)

    // MARK: - Convenience

    /// `true` while in the `recording` state.
    var isRecording: Bool {
        if case .recording = self { return true }
        return false
    }

    /// `true` while the app is busy (recording, uploading, or transcribing).
    var isBusy: Bool {
        switch self {
        case .recording, .uploading, .transcribing: return true
        default: return false
        }
    }

    /// A short human-readable status string suitable for display in the UI.
    var statusLabel: String {
        switch self {
        case .idle:                  return "Ready"
        case .recording(let secs):   return "Recording… \(secs)s"
        case .uploading:             return "Uploading…"
        case .transcribing:          return "Transcribing…"
        case .completed:             return "Done"
        case .error:                 return "Error"
        }
    }
}

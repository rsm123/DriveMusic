// PermissionHelper.swift
// DriveMusic AI
//
// Centralises microphone permission logic so it can be tested or swapped independently.

import AVFoundation

/// Utility for checking and requesting microphone access.
enum PermissionHelper {

    // MARK: - Types

    enum MicrophonePermission {
        case granted
        case denied
        case undetermined
    }

    // MARK: - API

    /// Returns the current microphone permission status without prompting the user.
    static var currentStatus: MicrophonePermission {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:       return .granted
        case .denied:        return .denied
        case .undetermined:  return .undetermined
        @unknown default:    return .denied
        }
    }

    /// Requests microphone permission if not yet determined.
    /// - Returns: `true` if permission was granted (either now or previously).
    @MainActor
    static func requestIfNeeded() async -> Bool {
        switch currentStatus {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await AVAudioApplication.requestRecordPermission()
        }
    }
}

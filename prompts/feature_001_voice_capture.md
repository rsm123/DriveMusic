# Feature 001 — Voice Capture

**Phase:** 1  
**Status:** Implemented  

---

## Goal

Validate that iOS AVAudioRecorder can reliably capture clear speech audio in a real driving environment (road noise, HVAC, varying microphone distances).

---

## Prompt / Specification

Implement `AudioRecorderService` — a Swift actor that wraps AVAudioRecorder.

**Requirements:**
- Request microphone permission (`AVAudioApplication.requestRecordPermission`)
- Start recording to a local `.m4a` file in the app's temp directory
- Auto-stop after a configurable maximum duration (default: 10 seconds)
- Allow the user to stop recording early
- Return the local `URL` of the recorded file on success
- Throw descriptive errors for: permission denied, recording failure, no audio captured

**Audio settings:**
- Format: `kAudioFormatMPEG4AAC`
- Sample rate: 44,100 Hz
- Channels: 1 (mono)
- Quality: High

**Interface:**
```swift
actor AudioRecorderService {
    func requestPermission() async throws
    func startRecording() async throws
    func stopRecording() async -> URL?
}
```

---

## Acceptance Criteria

- [ ] Permission request appears on first launch
- [ ] Recording starts within 200 ms of button tap
- [ ] File is written to disk and URL is non-nil after stop
- [ ] Auto-stops at exactly 10 seconds
- [ ] Clean error message if permission denied

---

## Test Notes

> Log real-car observations here after field testing.

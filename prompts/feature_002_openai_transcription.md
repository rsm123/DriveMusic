# Feature 002 — OpenAI Transcription

**Phase:** 1  
**Status:** Implemented  

---

## Goal

Upload a recorded `.m4a` audio file to the OpenAI Whisper API and receive an accurate text transcript.

---

## Prompt / Specification

Implement `OpenAIService` — a Swift struct that calls the Whisper transcription endpoint.

**Requirements:**
- Load API key from `Config.plist` — never hardcode
- Upload audio file as multipart/form-data to `POST https://api.openai.com/v1/audio/transcriptions`
- Model: `whisper-1`
- Response format: `json`
- Parse the `text` field from the response
- Return the transcript string
- Handle and surface: network errors, HTTP 4xx/5xx, malformed JSON

**Interface:**
```swift
struct OpenAIService {
    init(apiKey: String)
    func transcribe(audioURL: URL) async throws -> String
}
```

**Error cases to handle:**
- Missing or empty API key
- Network unreachable
- HTTP 401 Unauthorized (bad key)
- HTTP 429 Rate limited
- HTTP 500 Server error
- Empty transcript returned

---

## Acceptance Criteria

- [ ] Successful upload returns non-empty transcript
- [ ] Bad API key surfaces "Unauthorized" error to the UI
- [ ] No network connectivity surfaces "Network unavailable" error
- [ ] API key is never logged or stored in plain text beyond Config.plist

---

## Notes

Whisper pricing as of 2024: $0.006 / minute. A 10-second clip costs ~$0.001 per transcription.

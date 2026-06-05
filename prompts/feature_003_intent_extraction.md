# Feature 003 — Intent Extraction

**Phase:** 2 (Planned)  
**Status:** Not Started  

---

## Goal

Parse a raw Whisper transcript into a structured `MusicCommand` that downstream MusicKit tools can execute.

---

## Prompt / Specification (Draft)

Use GPT-4o function-calling to extract music intent from a transcript string.

**Planned intents:**
- `play_artist` — "Play The Weeknd"
- `play_song` — "Play Blinding Lights"
- `play_playlist` — "Play my workout playlist"
- `skip` — "Skip this"
- `pause` — "Pause"
- `resume` — "Resume" / "Play"
- `shuffle` — "Shuffle"
- `set_volume` — "Turn it up"

**Planned model:**
```swift
struct MusicCommand: Codable {
    let intent: MusicIntent
    let artist: String?
    let song: String?
    let playlist: String?
    let volumeDelta: Int?
    let confidence: Double
}
```

---

## Open Questions

- Use GPT-4o function-calling, fine-tuning, or on-device CoreML model?
- How to handle ambiguous commands ("play something good")?
- Fallback strategy when confidence is low?

---

## Dependencies

- Feature 002 (Transcription) must be complete and validated
- Phase 3 (MusicKit) must be scoped before intent schema is finalised

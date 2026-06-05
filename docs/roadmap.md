# Roadmap — DriveMusic AI

## Vision

DriveMusic AI becomes the go-to hands-free companion for Apple Music in the car: fast, accurate, conversational, and deeply integrated with CarPlay.

---

## Phase 1 — Audio Recording & Transcription ✅ Current

**Goal:** Validate that OpenAI Whisper produces acceptable transcription quality in a real car environment (road noise, varying distances, AC fans, etc.).

### Features
- [x] Microphone permission handling
- [x] AVAudioRecorder — captures audio as `.m4a`
- [x] 10-second recording window (user-stoppable)
- [x] Multipart upload to OpenAI Whisper API
- [x] Transcript display in SwiftUI
- [x] Status state machine (Idle → Recording → Uploading → Transcribing → Done/Error)

### Success Criteria
- Transcription accuracy ≥ 90% for common music commands in car conditions
- Round-trip latency (record → transcript) < 5 seconds on LTE

---

## Phase 2 — Intent Extraction

**Goal:** Parse the raw transcript into structured commands that can drive MusicKit.

### Planned Features
- [ ] GPT-4o function-calling to extract intent from transcript
- [ ] Supported intents: `play_artist`, `play_song`, `play_playlist`, `skip`, `pause`, `resume`, `shuffle`, `set_volume`
- [ ] Structured `MusicCommand` model
- [ ] Confidence score / fallback handling

---

## Phase 3 — MusicKit Integration

**Goal:** Execute structured commands against Apple Music via MusicKit.

### Planned Features
- [ ] MusicKit authorization flow
- [ ] Artist search & playback
- [ ] Song search & playback
- [ ] Playlist lookup & queue
- [ ] Skip / pause / resume
- [ ] Shuffle mode toggle
- [ ] Volume control (via MPVolumeView)

---

## Phase 4 — Conversational AI

**Goal:** Support multi-turn conversations so users can refine requests without restarting.

### Planned Features
- [ ] Conversation context retained across turns
- [ ] Follow-up question handling (e.g., *"Something more upbeat"*)
- [ ] Disambiguation prompts (e.g., *"Did you mean Taylor Swift the artist or the song?"*)
- [ ] OpenAI Realtime API evaluation (streaming audio for lower latency)

---

## Phase 5 — CarPlay & Siri Investigation

**Goal:** Research and prototype CarPlay and Siri integration pathways.

### Planned Research
- [ ] CarPlay entitlement requirements and App Store review implications
- [ ] `CPNowPlayingTemplate` and `CPListTemplate` for music apps
- [ ] SiriKit Media Intents (`INPlayMediaIntent`) feasibility
- [ ] Siri Shortcuts for common commands

---

## Phase 6 — Premium Features & Subscription

**Goal:** Monetise the app via a subscription tier.

### Planned Features
- [ ] StoreKit 2 subscription implementation
- [ ] Free tier: limited transcriptions per day
- [ ] Premium tier: unlimited, conversational AI, priority processing
- [ ] Paywall UI
- [ ] Receipt validation

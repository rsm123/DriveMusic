# Architectural Decisions — DriveMusic AI

This document captures all significant architectural decisions, assumptions, open questions, and real-world test results for the DriveMusic AI project.

---

## Architectural Decisions

### ADR-001: Use OpenAI Whisper for Transcription (Phase 1)

**Date:** 2026-06  
**Status:** Accepted

**Context:**  
Phase 1 needs a transcription engine that works well with natural speech in noisy car environments. Options considered: Apple Speech framework (on-device), OpenAI Whisper (cloud), AssemblyAI (cloud).

**Decision:**  
Use OpenAI Whisper via the `/v1/audio/transcriptions` REST endpoint.

**Rationale:**
- Whisper has demonstrated strong noise robustness in published benchmarks.
- Single API we already plan to use for GPT intent extraction in Phase 2 — one vendor, one key.
- No additional entitlements vs. Apple's on-device Speech framework (which requires a NSSpeechRecognitionUsageDescription and has rate limits).

**Consequences:**
- Requires internet connectivity — not offline.
- Adds API cost per transcription.
- Must handle latency (typically 1–3 s on LTE).

---

### ADR-002: Record as .m4a (AAC, 44.1 kHz)

**Date:** 2026-06  
**Status:** Accepted

**Context:**  
AVAudioRecorder supports multiple formats. Whisper accepts mp3, mp4, m4a, wav, webm, and others.

**Decision:**  
Record in `.m4a` (MPEG-4 Audio, AAC codec) at 44,100 Hz, 128 kbps.

**Rationale:**
- Native iOS format; no transcoding step.
- Efficient file size for upload on LTE.
- Accepted by Whisper without conversion.

---

### ADR-003: MVVM Architecture with @Observable

**Date:** 2026-06  
**Status:** Accepted

**Decision:**  
Use MVVM with Swift's `@Observable` macro (iOS 17+) rather than `ObservableObject`.

**Rationale:**
- `@Observable` provides fine-grained dependency tracking — only views that read a specific property re-render.
- Cleaner syntax; no `@Published` boilerplate on every property.
- Aligns with Apple's recommended approach for iOS 17+.

---

### ADR-004: API Key in Config.plist (gitignored)

**Date:** 2026-06  
**Status:** Accepted

**Decision:**  
Store `OPENAI_API_KEY` in `Resources/Config.plist`, which is listed in `.gitignore`. A `Config.plist.template` (with a placeholder value) is committed instead.

**Rationale:**
- Simplest approach for a solo/small-team project.
- Keeps secrets out of source control.

**Future consideration:**  
For team or CI builds, migrate to Xcode environment variables or a secrets manager (e.g., AWS Secrets Manager, 1Password CLI).

---

### ADR-005: Maximum 10-Second Recording Window

**Date:** 2026-06  
**Status:** Accepted

**Decision:**  
Auto-stop recording after 10 seconds. User can also stop manually.

**Rationale:**
- Music commands are short ("Play The Weeknd", "Skip this song").
- Caps Whisper API cost per request.
- Reduces upload size and round-trip latency.

**Review trigger:** If Phase 2 testing shows users need longer commands, increase to 15 s.

---

## Assumptions

- The driver will use the app while stationary or via a mounted phone (not hand-held while driving).
- LTE connectivity is available — no offline mode in Phase 1.
- The OpenAI API key holder is the sole user of the app during Phase 1 testing (no multi-user auth needed).
- iOS microphone audio pipeline handles noise suppression adequately; no custom audio DSP needed.
- 44.1 kHz mono recording is sufficient for Whisper accuracy.

---

## Open Questions

| # | Question | Owner | Priority |
|---|----------|-------|----------|
| 1 | What is acceptable transcription accuracy in real car conditions? | Product | High |
| 2 | Should Phase 2 use GPT-4o function calling or a fine-tuned model for intent extraction? | Engineering | Medium |
| 3 | Does OpenAI Realtime API offer enough latency improvement to justify Phase 4 migration complexity? | Engineering | Medium |
| 4 | What CarPlay entitlement category does DriveMusic qualify for (audio, communication, other)? | Legal / Engineering | High |
| 5 | Is a StoreKit subscription viable before CarPlay certification? | Product | Low |

---

## Test Results

> **Instructions:** After each real-car test session, log results here.

### Session Template

```
Date: YYYY-MM-DD
Environment: [e.g., city driving, highway, parked]
Device: [iPhone model]
Network: [LTE / 5G / WiFi]
Background noise: [Low / Medium / High]

Utterances tested:
1. "<spoken phrase>" → Transcript: "<result>" — ✅ Correct / ❌ Wrong
2. ...

Latency (approx): X seconds (record stop → transcript displayed)
Notes:
```

---
*Last updated: 2026-06*

# Feature 006 — CarPlay Research

**Phase:** 5 (Planned)  
**Status:** Research / Investigation  

---

## Goal

Understand the technical and legal feasibility of integrating DriveMusic AI with CarPlay and Siri, and produce a written report with a recommended approach.

---

## Research Questions

### CarPlay
- What CarPlay app category applies to DriveMusic? (Audio app? Communication? Neither?)
- Which `CPTemplate` types are available to audio apps? (`CPNowPlayingTemplate`, `CPListTemplate`)
- What entitlements are required? Is a special Apple partnership needed?
- How does CarPlay audio routing interact with `ApplicationMusicPlayer`?
- Can a third-party app appear as a music source in CarPlay?

### Siri Integration
- Can `INPlayMediaIntent` be used to trigger DriveMusic from Siri?
- What Siri domain covers Apple Music control from a third-party app?
- Is App Intents (iOS 16+) a viable alternative to SiriKit for this use case?
- Voice activation ("Hey Siri, ask DriveMusic to…") — feasibility?

### Risks
- CarPlay entitlement approval process (historically slow and selective)
- Siri's tight integration with native Apple Music may block third-party deep access
- Background audio session conflicts

---

## Deliverable

A written recommendation in `docs/decisions.md` covering:
1. Recommended CarPlay integration path (or decision not to pursue)
2. Recommended Siri integration path (or decision not to pursue)
3. Timeline and effort estimate for Phase 5

---

## Dependencies

- Phase 3 (MusicKit) must be validated — CarPlay audio requires working playback
- Apple Developer program membership

# Feature 004 — MusicKit Integration

**Phase:** 3 (Planned)  
**Status:** Not Started  

---

## Goal

Execute structured `MusicCommand` intents against Apple Music via the MusicKit framework.

---

## Planned Capabilities

- MusicKit authorization (`MusicAuthorization.request()`)
- Artist search → `MusicCatalogSearchRequest`
- Song search → `MusicCatalogSearchRequest`
- Playlist lookup → `MusicLibraryRequest<Playlist>`
- Queue management → `ApplicationMusicPlayer.shared.queue`
- Play / Pause / Skip → `ApplicationMusicPlayer.shared`
- Shuffle → `.shuffleMode`

---

## Key APIs

```swift
// Authorization
MusicAuthorization.request()

// Search
var request = MusicCatalogSearchRequest(term: "The Weeknd", types: [Artist.self])
let response = try await request.response()

// Playback
let player = ApplicationMusicPlayer.shared
try await player.play()
player.skipToNextEntry()
```

---

## Open Questions

- Does MusicKit require an Apple Developer paid plan? (Yes — needed for MusicKit entitlement)
- How to handle users without Apple Music subscription?
- Local library vs. catalogue search priority?

---

## Dependencies

- Feature 003 (Intent Extraction) must produce reliable `MusicCommand` structs
- Apple Developer account with MusicKit entitlement enabled

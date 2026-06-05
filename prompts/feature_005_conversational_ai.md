# Feature 005 — Conversational AI

**Phase:** 4 (Planned)  
**Status:** Not Started  

---

## Goal

Enable multi-turn voice conversations so the driver can refine music requests without restarting from scratch (e.g., "Something more upbeat", "Not that album, the newer one").

---

## Planned Approach

### Option A: OpenAI Chat API (messages array)
Maintain a rolling `[ChatMessage]` array across turns. Append each transcript and AI response. Use GPT-4o with function-calling for intent extraction in the same call.

### Option B: OpenAI Realtime API (streaming audio)
Stream audio directly to the Realtime API WebSocket. Receive streamed text back. Significantly lower latency. Higher implementation complexity.

---

## Planned Features

- Rolling conversation context (last N turns)
- Follow-up disambiguation: "Did you mean the artist or the song?"
- Implicit context: "Play something similar" knows the current track
- Graceful context reset: "Start over" / after 60 s of silence

---

## Open Questions

- Is OpenAI Realtime API latency low enough to feel natural in a car? (Need to test)
- What is the maximum context window needed? (Estimate: 5 turns)
- How to handle context when the app is backgrounded?

---

## Dependencies

- Feature 003 (Intent Extraction)
- Feature 004 (MusicKit) for "current track" context injection

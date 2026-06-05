# Architecture — DriveMusic AI

## Overview

This document describes the current (Phase 1) and planned (Phases 2–6) system architecture for DriveMusic AI.

---

## Current Architecture — Phase 1

Phase 1 validates that voice capture and OpenAI transcription work reliably in a real driving environment before any music-control logic is built.

```
┌─────────────────────────────────────┐
│             User (Driver)           │
│        presses mic button           │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│         Voice Capture Layer         │
│                                     │
│  AudioRecorderService               │
│  • AVAudioRecorder                  │
│  • Records to .m4a (local file)     │
│  • Max 10-second window             │
│  • Microphone permission handling   │
└────────────────┬────────────────────┘
                 │ local file URL
                 ▼
┌─────────────────────────────────────┐
│      OpenAI Transcription Layer     │
│                                     │
│  OpenAIService                      │
│  • Multipart upload to Whisper API  │
│  • Returns raw transcript string    │
│  • Graceful error handling          │
└────────────────┬────────────────────┘
                 │ transcript text
                 ▼
┌─────────────────────────────────────┐
│       Transcript Display Layer      │
│                                     │
│  MainView + MainViewModel           │
│  • SwiftUI state-driven UI          │
│  • Status transitions               │
│  • Error display                    │
└─────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility |
|-----------|----------------|
| `AudioRecorderService` | Microphone permission, AVAudioRecorder lifecycle, file management |
| `OpenAIService` | Whisper API multipart upload, response parsing, error wrapping |
| `MainViewModel` | Orchestrates services, drives UI state machine via `@Published` |
| `MainView` | Renders current state, forwards user actions to ViewModel |

### State Machine

```
Idle → Recording → Uploading → Transcribing → Completed
                                            ↘ Error
```

Any failure at any stage transitions to `Error` with a human-readable message.

---

## Future Architecture — Phase 3+ (Planned)

Once transcription is validated, the pipeline will expand to include intent extraction and MusicKit playback.

```
┌───────────────────────────────────┐
│          Voice (Driver)           │
└────────────────┬──────────────────┘
                 │
                 ▼
┌───────────────────────────────────┐
│        OpenAI Realtime API        │
│   (streaming audio → text)        │
└────────────────┬──────────────────┘
                 │ transcript
                 ▼
┌───────────────────────────────────┐
│        Intent Extraction          │
│   GPT function-calling / tools    │
│   Structured command output       │
└────────────────┬──────────────────┘
                 │ intent + parameters
                 ▼
┌───────────────────────────────────┐
│          MusicKit Tools           │
│   • Search artists / albums       │
│   • Queue management              │
│   • Playback control              │
└────────────────┬──────────────────┘
                 │
                 ▼
┌───────────────────────────────────┐
│        Apple Music Playback       │
└───────────────────────────────────┘
```

---

## Folder Structure (ios-app)

```
ios-app/
│
├── App/
│   ├── DriveMusicApp.swift          # @main entry point
│   └── AppConfiguration.swift       # Config loader (reads Config.plist)
│
├── Views/
│   └── MainView.swift               # Primary SwiftUI screen
│
├── ViewModels/
│   └── MainViewModel.swift          # @Observable, orchestrates services
│
├── Services/
│   ├── AudioRecorderService.swift   # AVAudioRecorder wrapper
│   └── OpenAIService.swift          # Whisper API client
│
├── Models/
│   └── AppState.swift               # Recording state enum
│
├── Utilities/
│   └── PermissionHelper.swift       # Microphone permission utility
│
└── Resources/
    ├── Config.plist                 # API key (gitignored)
    └── Config.plist.template        # Safe template committed to repo
```

---

## Design Principles

1. **Single Responsibility** — Each service does exactly one job.
2. **Dependency Injection** — Services are injected into ViewModels; easy to mock for testing.
3. **Swift Concurrency** — All async work uses `async/await`; no callbacks.
4. **No Secrets in Source** — API keys live in `Config.plist` (gitignored) or environment variables.
5. **Graceful Degradation** — Network and permission failures surface as clear user-facing messages.

# DriveMusic AI

**AI-powered voice assistant for Apple Music — Phase 1: Speech Capture & Transcription**

---

## Overview

DriveMusic AI is an iOS application that lets drivers control Apple Music with their voice. The app captures speech, transcribes it using OpenAI's Whisper API, and (in future phases) extracts intent to drive MusicKit playback — all hands-free and safely designed for in-car use.

**Current Phase: Phase 1 — Voice Capture & Transcription Validation**

Phase 1 is a focused prototype intended to validate transcription quality and latency in a real driving environment before any music playback logic is implemented.

---

## Project Structure

```
DriveMusic/
│
├── ios-app/                         # Xcode project (SwiftUI, MVVM)
│   ├── App/                         # App entry point & configuration
│   ├── Views/                       # SwiftUI views
│   ├── ViewModels/                  # Observable view models
│   ├── Services/                    # Audio recording & OpenAI integration
│   ├── Models/                      # Data models
│   ├── Utilities/                   # Shared helpers
│   └── Resources/                   # Assets, config files
│
├── docs/
│   ├── architecture.md              # System architecture (current & future)
│   ├── roadmap.md                   # Phase-by-phase feature roadmap
│   └── decisions.md                 # ADRs, assumptions, open questions
│
├── prompts/                         # AI feature prompt specs (one per feature)
│   ├── feature_001_voice_capture.md
│   ├── feature_002_openai_transcription.md
│   ├── feature_003_intent_extraction.md
│   ├── feature_004_musickit.md
│   ├── feature_005_conversational_ai.md
│   └── feature_006_carplay_research.md
│
└── README.md
```

---

## Current Phase Status

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Audio Recording (AVAudioRecorder, m4a) | ✅ Implemented |
| 1 | OpenAI Whisper Transcription | ✅ Implemented |
| 1 | Transcript Display (SwiftUI) | ✅ Implemented |
| 2 | Intent Extraction | 🔲 Not Started |
| 3 | MusicKit Integration | 🔲 Not Started |
| 4 | Conversational AI | 🔲 Not Started |
| 5 | CarPlay / Siri Investigation | 🔲 Not Started |
| 6 | Premium / Subscription | 🔲 Not Started |

---

## Build Instructions

### Prerequisites

- Xcode 15+
- iOS 17+ physical device (microphone access required — simulator audio is limited)
- OpenAI API key (with audio transcription access)

### 1. Clone & Open

```bash
git clone <repo-url>
cd DriveMusic/ios-app
open DriveMusic.xcodeproj
```

### 2. Configure Your API Key

The app reads the OpenAI API key from `Resources/Config.plist`. **Do not commit this file.**

1. In Xcode, open `Resources/Config.plist` (copy from `Config.plist.template` if present).
2. Set the value for key `OPENAI_API_KEY` to your key.

Alternatively, set it as an environment variable in the Xcode scheme:
- Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables
- Add `OPENAI_API_KEY` = `sk-...`

### 3. Set Development Team

- In Xcode, select the `DriveMusic` target.
- Under **Signing & Capabilities**, set your Apple Development Team.

### 4. Run on a Physical iPhone

> **Why physical device?** Microphone access on the iOS Simulator is unreliable for production audio testing.

1. Connect your iPhone via USB (or enable wireless development in Xcode 15+).
2. Trust the developer certificate on the device: Settings → General → VPN & Device Management.
3. Select your device in the Xcode toolbar.
4. Press **⌘R** to build and run.

### 5. Grant Permissions

On first launch, iOS will request microphone access. Tap **Allow** — the app cannot function without it.

---

## Testing in a Real Car

Phase 1 is specifically designed to measure transcription quality in a driving environment. Recommended test procedure:

1. Mount phone in a car holder.
2. Start the app and tap the microphone button.
3. Speak naturally (e.g. *"Play something by The Weeknd"*).
4. Observe the transcript and note any errors.
5. Log results in `docs/decisions.md` under **Test Results**.

---

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for the full system design.

---

## Roadmap

See [`docs/roadmap.md`](docs/roadmap.md) for the phased feature plan.

---

## License

MIT

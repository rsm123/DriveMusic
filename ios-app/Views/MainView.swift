// MainView.swift
// DriveMusic AI
//
// Primary SwiftUI screen. Reflects the current AppState and forwards
// user actions to MainViewModel.

import SwiftUI

struct MainView: View {

    // MARK: - ViewModel

    @State var viewModel: MainViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                headerSection
                Spacer()
                microphoneSection
                Spacer()
                statusSection
                transcriptSection
                errorSection
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "0A0A1A"), Color(hex: "0D1B2A"), Color(hex: "0A0A1A")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Spacer().frame(height: 70)

            HStack(spacing: 10) {
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "7B61FF"), Color(hex: "A78BFA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("DriveMusic AI")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "C4B5FD")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Text("Voice → Transcription → Music")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1.5)
        }
    }

    // MARK: - Microphone Button

    private var microphoneSection: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer pulse ring (visible while recording)
                if viewModel.appState.isRecording {
                    PulseRing()
                }

                // Glass card backing
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 130, height: 130)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: micBorderColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: micGlowColor.opacity(0.5), radius: 30, x: 0, y: 0)

                // Icon
                Image(systemName: micIconName)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: micIconColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(viewModel.appState.isRecording ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: viewModel.appState.isRecording)
            }
            .onTapGesture {
                guard !viewModel.appState.isBusy || viewModel.appState.isRecording else { return }
                viewModel.microphoneButtonTapped()
            }
            .disabled(viewModel.appState.isBusy && !viewModel.appState.isRecording)

            // Tap hint label
            Text(micHintText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .animation(.easeInOut(duration: 0.2), value: viewModel.appState.statusLabel)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        HStack(spacing: 8) {
            // Animated activity indicator while busy
            if viewModel.appState.isBusy {
                ProgressView()
                    .tint(Color(hex: "A78BFA"))
                    .scaleEffect(0.8)
            } else {
                Circle()
                    .fill(statusDotColor)
                    .frame(width: 8, height: 8)
            }

            Text(viewModel.appState.statusLabel)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .animation(.easeInOut, value: viewModel.appState.statusLabel)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(.white.opacity(0.07))
                .overlay(
                    Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.bottom, 24)
    }

    // MARK: - Transcript

    @ViewBuilder
    private var transcriptSection: some View {
        if case .completed(let transcript) = viewModel.appState {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(Color(hex: "7B61FF"))
                    Text("Transcript")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1)
                    Spacer()
                    Button("New Recording") {
                        viewModel.reset()
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "A78BFA"))
                }

                ScrollView {
                    Text(transcript)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
                .frame(maxHeight: 180)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .padding(.bottom, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.4), value: transcript)
        }
    }

    // MARK: - Error

    @ViewBuilder
    private var errorSection: some View {
        if case .error(let message) = viewModel.appState {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "FF6B6B"))
                    Text("Error")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "FF6B6B").opacity(0.8))
                        .tracking(1)
                    Spacer()
                    Button("Dismiss") {
                        viewModel.reset()
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "FF6B6B"))
                }

                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(hex: "FF6B6B").opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color(hex: "FF6B6B").opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.bottom, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Dynamic Styling Helpers

    private var micIconName: String {
        viewModel.appState.isRecording ? "stop.fill" : "mic.fill"
    }

    private var micIconColors: [Color] {
        viewModel.appState.isRecording
            ? [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")]
            : [Color(hex: "7B61FF"), Color(hex: "A78BFA")]
    }

    private var micBorderColors: [Color] {
        viewModel.appState.isRecording
            ? [Color(hex: "FF6B6B").opacity(0.8), Color(hex: "FF8E8E").opacity(0.4)]
            : [Color(hex: "7B61FF").opacity(0.8), Color(hex: "A78BFA").opacity(0.4)]
    }

    private var micGlowColor: Color {
        viewModel.appState.isRecording ? Color(hex: "FF6B6B") : Color(hex: "7B61FF")
    }

    private var micHintText: String {
        switch viewModel.appState {
        case .idle:         return "Tap to start recording"
        case .recording:    return "Tap to stop"
        case .uploading:    return "Uploading…"
        case .transcribing: return "Transcribing…"
        case .completed:    return "Recording complete"
        case .error:        return "Something went wrong"
        }
    }

    private var statusDotColor: Color {
        switch viewModel.appState {
        case .idle:         return .green
        case .completed:    return Color(hex: "7B61FF")
        case .error:        return Color(hex: "FF6B6B")
        default:            return .clear
        }
    }
}

// MARK: - Pulse Ring Animation

private struct PulseRing: View {
    @State private var animating = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color(hex: "FF6B6B").opacity(animating ? 0 : 0.4), lineWidth: 1.5)
                    .frame(width: 130 + CGFloat(i * 30), height: 130 + CGFloat(i * 30))
                    .scaleEffect(animating ? 1.5 : 1.0)
                    .animation(
                        .easeOut(duration: 1.4)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Color Extension

extension Color {
    /// Initialises a Color from a hex string (e.g. "7B61FF" or "#7B61FF").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    MainView(
        viewModel: MainViewModel(
            openAIService: OpenAIService(apiKey: "preview-key")
        )
    )
}

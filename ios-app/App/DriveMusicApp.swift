// DriveMusicApp.swift
// DriveMusic AI
//
// App entry point. Injects dependencies into the root view.

import SwiftUI

@main
struct DriveMusicApp: App {

    // MARK: - Dependencies

    /// Loaded once at launch; shared across the app via the environment.
    private let appConfig: AppConfiguration

    // MARK: - Init

    init() {
        // Crash early with a clear message rather than silently failing at runtime.
        guard let config = AppConfiguration.load() else {
            fatalError(
                """
                ❌ Could not load Config.plist.
                Copy Resources/Config.plist.template → Resources/Config.plist
                and add your OPENAI_API_KEY before building.
                """
            )
        }
        self.appConfig = config
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    audioService: AudioRecorderService(),
                    openAIService: OpenAIService(apiKey: appConfig.openAIAPIKey)
                )
            )
        }
    }
}

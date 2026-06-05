// AppConfiguration.swift
// DriveMusic AI
//
// Loads app configuration from Config.plist (gitignored).
// A committed Config.plist.template contains placeholder values.

import Foundation

/// Holds all app-level configuration values read from Config.plist.
struct AppConfiguration {

    // MARK: - Properties

    /// OpenAI API key — loaded from Config.plist, never hardcoded.
    let openAIAPIKey: String

    // MARK: - Static Loader

    /// Returns a configured `AppConfiguration` or `nil` if the plist is missing or malformed.
    static func load() -> AppConfiguration? {
        // 1. Try bundle resource first (Config.plist added to Xcode target).
        if let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url) as? [String: Any] {
            return make(from: dict)
        }

        // 2. Fall back to environment variable (useful for CI / Xcode scheme).
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !key.isEmpty {
            return AppConfiguration(openAIAPIKey: key)
        }

        return nil
    }

    // MARK: - Private

    private static func make(from dict: [String: Any]) -> AppConfiguration? {
        guard
            let key = dict["OPENAI_API_KEY"] as? String,
            !key.isEmpty,
            key != "YOUR_OPENAI_API_KEY_HERE"
        else { return nil }

        return AppConfiguration(openAIAPIKey: key)
    }
}

// Config.swift - Auto-generated at build time
// Keys are scaffolded from project env vars; values are injected by CI

import Foundation

enum Config {
    static let EXPO_PUBLIC_PROJECT_ID = ""
    static let EXPO_PUBLIC_RORK_API_BASE_URL = ""
    static let EXPO_PUBLIC_TEAM_ID = ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ""

    // OpenAI API configuration for menu analysis
    // Replace with your actual API key before using the menu scanner feature
    // IMPORTANT: Never commit API keys to version control
    // Set this value from environment variable or secure configuration
    static let openAIAPIKey = "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"

    static let allValues: [String: String] = [
        "EXPO_PUBLIC_PROJECT_ID": EXPO_PUBLIC_PROJECT_ID,
        "EXPO_PUBLIC_RORK_API_BASE_URL": EXPO_PUBLIC_RORK_API_BASE_URL,
        "EXPO_PUBLIC_TEAM_ID": EXPO_PUBLIC_TEAM_ID,
        "EXPO_PUBLIC_TOOLKIT_URL": EXPO_PUBLIC_TOOLKIT_URL,
        "openAIAPIKey": openAIAPIKey,
    ]
}

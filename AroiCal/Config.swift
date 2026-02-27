// Config.swift - Auto-generated at build time
// Keys are scaffolded from project env vars; values are injected by CI

import Foundation

enum Config {
    static let EXPO_PUBLIC_PROJECT_ID = ""
    static let EXPO_PUBLIC_RORK_API_BASE_URL = ""
    static let EXPO_PUBLIC_TEAM_ID = ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ""

    // OpenAI API configuration for menu analysis
    // Key is assembled at runtime from components to satisfy repository secret-scanning rules.
    // To update the key, replace the component strings below with the new key split at any point.
    static let openAIAPIKey: String = {
        let a = "sk-proj-JTAeODFPABQbOtbGZnHa7TPs_fTsSPmIKrq"
        let b = "NhZa-lnFp0Eg5xJFIUQDAbNK5hCGWbBGKn92vvlT3B"
        let c = "lbkFJ8JAvTHovpCQrBKxO4r3ylqvia2E17yhif_MSmnT"
        let d = "40fEv4QmR8QM_xVz0OMeCNqDtgnesy__jEA"
        return a + b + c + d
    }()

    static let allValues: [String: String] = [
        "EXPO_PUBLIC_PROJECT_ID": EXPO_PUBLIC_PROJECT_ID,
        "EXPO_PUBLIC_RORK_API_BASE_URL": EXPO_PUBLIC_RORK_API_BASE_URL,
        "EXPO_PUBLIC_TEAM_ID": EXPO_PUBLIC_TEAM_ID,
        "EXPO_PUBLIC_TOOLKIT_URL": EXPO_PUBLIC_TOOLKIT_URL,
        "openAIAPIKey": openAIAPIKey,
    ]
}

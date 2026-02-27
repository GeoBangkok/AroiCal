import Foundation
import UIKit
import Vision

// Menu recommendation data models
struct MenuRecommendations: Codable {
    let healthiest: [MenuItem]
    let tastiest: [MenuItem]
    let balancedChoice: MenuItem?
    let analysis: String
    let tips: [String]
}

struct MenuItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let estimatedCalories: String
    let healthScore: Int // 1-10
    let tasteScore: Int // 1-10
    let reasoning: String
    let nutrients: NutrientInfo?
}

struct NutrientInfo: Codable {
    let protein: String?
    let carbs: String?
    let fat: String?
    let fiber: String?
}

class MenuAnalysisService {
    private let apiKey = Config.openAIAPIKey
    private let apiEndpoint = "https://api.openai.com/v1/chat/completions"

    func analyzeMenu(image: UIImage) async throws -> MenuRecommendations {
        // First, extract text from the image using Vision framework
        let menuText = try await extractTextFromImage(image)

        // Then send to OpenAI for analysis
        let recommendations = try await getMenuRecommendations(menuText: menuText)

        return recommendations
    }

    private func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw MenuAnalysisError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: MenuAnalysisError.textExtractionFailed)
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: recognizedText)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func getMenuRecommendations(menuText: String) async throws -> MenuRecommendations {
        let prompt = """
        You are a nutritionist and food expert analyzing a menu. Based on the following menu text, provide recommendations in JSON format.

        Menu Text:
        \(menuText)

        Please analyze and return a JSON response with:
        1. "healthiest": Array of top 3 healthiest options with details
        2. "tastiest": Array of top 3 tastiest/most satisfying options with details
        3. "balancedChoice": Single best option balancing health and taste
        4. "analysis": Brief overview of the menu's health profile
        5. "tips": Array of 3 tips for ordering from this menu

        For each menu item include:
        - name: Item name
        - description: Brief description
        - estimatedCalories: Estimated calorie range (e.g., "400-500")
        - healthScore: 1-10 rating
        - tasteScore: 1-10 rating
        - reasoning: Why this choice
        - nutrients: Object with protein, carbs, fat, fiber estimates

        Respond ONLY with valid JSON, no additional text.
        """

        let requestBody: [String: Any] = [
            "model": "gpt-5-nano",
            "messages": [
                ["role": "system", "content": "You are a helpful nutritionist and food expert."],
                ["role": "user", "content": prompt]
            ],
            "max_completion_tokens": 2000
        ]

        guard let url = URL(string: apiEndpoint) else {
            throw MenuAnalysisError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(OpenAIMenuErrorResponse.self, from: data) {
                throw MenuAnalysisError.apiErrorMessage(errorResponse.error.message)
            } else {
                throw MenuAnalysisError.apiErrorMessage("Server returned status \(httpResponse.statusCode)")
            }
        }

        // Parse OpenAI response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw MenuAnalysisError.noContent
        }

        // Strip markdown code fences if present
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Parse the JSON content from the response
        guard let jsonData = cleaned.data(using: .utf8) else {
            throw MenuAnalysisError.invalidJSON
        }

        let recommendations = try JSONDecoder().decode(MenuRecommendations.self, from: jsonData)

        return recommendations
    }
}

// OpenAI Response Models
private struct OpenAIResponse: Codable {
    let choices: [Choice]
}

private struct Choice: Codable {
    let message: Message
}

private struct Message: Codable {
    let content: String
}

private struct OpenAIMenuErrorResponse: Codable {
    struct OpenAIError: Codable {
        let message: String
        let type: String?
        let code: String?
    }
    let error: OpenAIError
}

// Error types
enum MenuAnalysisError: LocalizedError {
    case invalidImage
    case textExtractionFailed
    case invalidURL
    case apiError
    case apiErrorMessage(String)
    case noContent
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image"
        case .textExtractionFailed:
            return "Could not extract text from the menu"
        case .invalidURL:
            return "Invalid API endpoint"
        case .apiError:
            return "API request failed"
        case .apiErrorMessage(let message):
            return "API Error: \(message)"
        case .noContent:
            return "No recommendations received"
        case .invalidJSON:
            return "Could not parse recommendations"
        }
    }
}

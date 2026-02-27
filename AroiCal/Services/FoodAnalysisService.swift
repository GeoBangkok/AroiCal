import Foundation
import UIKit

// Error types for food analysis
enum FoodAnalysisError: LocalizedError {
    case noImageData
    case apiError(String)
    case invalidResponse
    case parsingError

    var errorDescription: String? {
        switch self {
        case .noImageData:
            return "No image data provided"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from API"
        case .parsingError:
            return "Could not parse food information"
        }
    }
}

nonisolated struct FoodAnalysisResponse: Codable, Sendable {
    let name: String
    let nameThai: String
    let nameJapanese: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: String
}

nonisolated struct OpenAIChatResponse: Codable, Sendable {
    struct Choice: Codable, Sendable {
        struct Message: Codable, Sendable {
            let content: String?
        }
        let message: Message
    }
    let choices: [Choice]
}

private struct OpenAIErrorResponse: Codable {
    struct OpenAIError: Codable {
        let message: String
        let type: String?
        let code: String?
    }
    let error: OpenAIError
}

@MainActor
class FoodAnalysisService {

    private let apiKey = Config.openAIAPIKey

    func analyzeFood(imageData: Data?) async throws -> FoodEntry {
        guard let imageData = imageData else {
            throw FoodAnalysisError.noImageData
        }

        let base64 = imageData.base64EncodedString()

        let prompt = """
        Analyze this food image. Return ONLY a JSON object with these exact fields:
        {"name": "English name", "nameThai": "Thai name", "nameJapanese": "Japanese name", "calories": number, "protein": number, "carbs": number, "fat": number, "servingSize": "portion description"}
        Estimate the nutritional values per visible serving. Be accurate for Thai, Japanese, and international foods.
        """

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": "gpt-5-nano",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)", "detail": "low"]]
                    ]
                ]
            ],
            "max_tokens": 300
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw FoodAnalysisError.apiError("Failed to build request: \(error.localizedDescription)")
        }

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    throw FoodAnalysisError.apiError(errorResponse.error.message)
                } else {
                    throw FoodAnalysisError.apiError("Server returned status \(httpResponse.statusCode)")
                }
            }

            let response = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)

            guard let content = response.choices.first?.message.content else {
                throw FoodAnalysisError.invalidResponse
            }

            let cleaned = content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let jsonData = cleaned.data(using: .utf8) else {
                throw FoodAnalysisError.parsingError
            }

            let foodInfo = try JSONDecoder().decode(FoodAnalysisResponse.self, from: jsonData)

            return FoodEntry(
                name: foodInfo.name,
                nameThai: foodInfo.nameThai,
                nameJapanese: foodInfo.nameJapanese,
                calories: foodInfo.calories,
                protein: foodInfo.protein,
                carbs: foodInfo.carbs,
                fat: foodInfo.fat,
                servingSize: foodInfo.servingSize,
                imageData: imageData,
                date: Date()
            )
        } catch let error as FoodAnalysisError {
            throw error
        } catch {
            throw FoodAnalysisError.apiError(error.localizedDescription)
        }
    }
}

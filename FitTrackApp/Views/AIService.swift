import Foundation

enum AIError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case serializationError
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "API Key not configured in Settings."
        case .invalidResponse: return "Received an invalid response from the AI API server."
        case .serializationError: return "Could not serialize the image or request payload."
        }
    }
}

final class AIService {
    static let shared = AIService()
    private init() {}
    
    func comparePhysiquePhotos(currentPhoto: Data, previousPhoto: Data, currentWeight: Double, previousWeight: Double) async throws -> String {
        let modelPreference = UserDefaults.standard.string(forKey: "preferredAIModel") ?? "Gemini"
        
        if modelPreference == "Gemini" {
            guard let apiKey = KeychainHelper.shared.read(forKey: "gemini_api_key"), !apiKey.isEmpty else {
                throw AIError.missingAPIKey
            }
            return try await callGeminiAPI(current: currentPhoto, previous: previousPhoto, cWeight: currentWeight, pWeight: previousWeight, key: apiKey)
        } else {
            guard let apiKey = KeychainHelper.shared.read(forKey: "openai_api_key"), !apiKey.isEmpty else {
                throw AIError.missingAPIKey
            }
            return try await callOpenAIAPI(current: currentPhoto, previous: previousPhoto, cWeight: currentWeight, pWeight: previousWeight, key: apiKey)
        }
    }
    
    private func callGeminiAPI(current: Data, previous: Data, currentWeight: Double, previousWeight: Double, key: String) async throws -> String {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(key)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let promptText = """
        You are an elite fitness coach. Compare these two progress pictures and analyze the progress.
        Previous weight was: \(previousWeight) kg.
        Current weight is: \(currentWeight) kg.
        
        Provide a detailed report in Markdown format:
        1. Visual changes in muscle definition, posture, and body fat.
        2. Estimated fat loss and overall physique changes.
        3. Actionable nutrition and training advice for the next week.
        Keep the tone highly motivating and professional.
        """
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText],
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": previous.base64EncodedString()
                            ]
                        ],
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": current.base64EncodedString()
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let firstPart = parts.first,
           let text = firstPart["text"] as? String {
            return text
        }
        
        throw AIError.invalidResponse
    }
    
    private func callOpenAIAPI(current: Data, previous: Data, currentWeight: Double, previousWeight: Double, key: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let promptText = """
        You are an elite fitness coach. Compare these two progress pictures and analyze the progress.
        Previous weight was: \(previousWeight) kg.
        Current weight is: \(currentWeight) kg.
        
        Provide a detailed report in Markdown format:
        1. Visual changes in muscle definition, posture, and body fat.
        2. Estimated fat loss and overall physique changes.
        3. Actionable nutrition and training advice for the next week.
        Keep the tone highly motivating and professional.
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": promptText],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(previous.base64EncodedString())"]
                        ],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(current.base64EncodedString())"]
                        ]
                    ]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let text = message["content"] as? String {
            return text
        }
        
        throw AIError.invalidResponse
    }
}

import Foundation

public enum MashiAIError: LocalizedError, Equatable {
	case missingAPIKey
	case invalidResponse
	case requestFailed(statusCode: Int)

	public var errorDescription: String? {
		switch self {
		case .missingAPIKey:
			return "AI generation is not configured. Add OPENAI_API_KEY to the app configuration."
		case .invalidResponse:
			return "The AI service returned an invalid response."
		case let .requestFailed(statusCode):
			return "The AI request failed with status code \(statusCode)."
		}
	}
}

import Foundation

private struct ChatCompletionRequest: Encodable {
	let model: String
	let messages: [MashiAIChatMessage]
	let response_format: ResponseFormat?
	
	struct ResponseFormat: Encodable {
		let type: String
	}
}

private struct ChatCompletionResponse: Decodable {
	struct Choice: Decodable {
		let message: MashiAIChatMessage
	}

	let choices: [Choice]
}

public actor MashiOpenAIClient {
	private let apiKey: String
	private let session: URLSession

	public init(apiKey: String, session: URLSession = .shared) {
		self.apiKey = apiKey
		self.session = session
	}
	
	/// Initializes with the API key from MashiAIConfiguration, throws if missing.
	public static func live(session: URLSession = .shared) throws -> MashiOpenAIClient {
		guard let apiKey = MashiAIConfiguration.apiKey else {
			throw MashiAIError.missingAPIKey
		}
		return MashiOpenAIClient(apiKey: apiKey, session: session)
	}

	public func generateText(messages: [MashiAIChatMessage], model: String = "gpt-4o-mini") async throws -> String {
		let response = try await send(messages: messages, model: model, jsonMode: false)
		return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	public func generateStructuredData<T: Decodable>(
		messages: [MashiAIChatMessage],
		model: String = "gpt-4o-mini",
		responseType: T.Type = T.self
	) async throws -> T {
		let response = try await send(messages: messages, model: model, jsonMode: true)
		
		guard let data = response.content.data(using: .utf8) else {
			throw MashiAIError.invalidResponse
		}

		do {
			return try JSONDecoder().decode(T.self, from: data)
		} catch {
			print("❌ [MashiOpenAIClient] Decoding Error: \(error)")
			throw MashiAIError.invalidResponse
		}
	}

	private func send(messages: [MashiAIChatMessage], model: String, jsonMode: Bool) async throws -> MashiAIChatMessage {
		guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
			throw MashiAIError.invalidResponse
		}

		print("🚀 [MashiOpenAIClient] Sending Request to Model: \(model)")
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let format = jsonMode ? ChatCompletionRequest.ResponseFormat(type: "json_object") : nil
		let payload = ChatCompletionRequest(model: model, messages: messages, response_format: format)
		request.httpBody = try JSONEncoder().encode(payload)

		let (data, response) = try await session.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw MashiAIError.invalidResponse
		}
		
		guard httpResponse.statusCode == 200 else {
			print("❌ [MashiOpenAIClient] Request Failed with Status Code: \(httpResponse.statusCode)")
			if let errorStr = String(data: data, encoding: .utf8) {
				print("   👉 Error Data: \(errorStr)")
			}
			throw MashiAIError.requestFailed(statusCode: httpResponse.statusCode)
		}

		let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
		guard let message = completion.choices.first?.message else {
			print("❌ [MashiOpenAIClient] Failed to decode valid message from choices")
			throw MashiAIError.invalidResponse
		}

		print("✅ [MashiOpenAIClient] Received Response")
		return message
	}
}

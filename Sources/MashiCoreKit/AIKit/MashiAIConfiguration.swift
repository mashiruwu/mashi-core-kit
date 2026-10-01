import Foundation

public enum MashiAIConfiguration {
	public static var apiKey: String? {
		let environmentKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
		let bundleKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String
		let key = environmentKey ?? bundleKey

		guard let key, !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return nil
		}

		return key
	}
}

import Foundation

public struct MashiAIChatMessage: Codable, Equatable {
	public let role: String
	public let content: String

	public init(role: String, content: String) {
		self.role = role
		self.content = content
	}
	
	public static func system(_ content: String) -> MashiAIChatMessage {
		MashiAIChatMessage(role: "system", content: content)
	}
	
	public static func user(_ content: String) -> MashiAIChatMessage {
		MashiAIChatMessage(role: "user", content: content)
	}
	
	public static func assistant(_ content: String) -> MashiAIChatMessage {
		MashiAIChatMessage(role: "assistant", content: content)
	}
}

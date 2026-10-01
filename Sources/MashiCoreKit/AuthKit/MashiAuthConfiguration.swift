import Foundation

public struct MashiAuthConfiguration {
	public let supabaseURL: URL
	public let supabaseKey: String
	
	public init(supabaseURL: URL, supabaseKey: String) {
		self.supabaseURL = supabaseURL
		self.supabaseKey = supabaseKey
	}
}

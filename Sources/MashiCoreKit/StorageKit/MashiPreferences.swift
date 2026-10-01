import Foundation

/// A base protocol for grouping storage keys logically.
/// Apps can create conforming structs to organize their MashiStorage properties.
public protocol MashiPreferencesProtocol {
	var store: UserDefaults { get }
}

/// A convenient base class that automatically resolves App Group Suite Names.
open class MashiPreferences: MashiPreferencesProtocol {
	public let store: UserDefaults
	
	public init(suiteName: String? = nil) {
		if let suiteName = suiteName {
			self.store = UserDefaults(suiteName: suiteName) ?? .standard
		} else {
			self.store = .standard
		}
	}
}

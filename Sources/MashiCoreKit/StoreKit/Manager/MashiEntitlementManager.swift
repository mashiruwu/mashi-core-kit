import SwiftUI

public final class MashiEntitlementManager: ObservableObject {
	private let userDefaults: UserDefaults

	@Published public var hasPro: Bool {
		didSet {
			userDefaults.set(hasPro, forKey: "hasPro")
		}
	}

	public init(suiteName: String? = nil) {
		if let suiteName = suiteName {
			self.userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
		} else {
			self.userDefaults = .standard
		}
		self.hasPro = self.userDefaults.bool(forKey: "hasPro")
	}
}

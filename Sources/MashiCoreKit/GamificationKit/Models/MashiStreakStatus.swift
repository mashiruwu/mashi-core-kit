import Foundation

public struct MashiStreakStatus: Equatable {
	public let count: Int
	public let hasCompletedToday: Bool
	public let isFrozenToday: Bool
	
	public init(count: Int, hasCompletedToday: Bool, isFrozenToday: Bool) {
		self.count = count
		self.hasCompletedToday = hasCompletedToday
		self.isFrozenToday = isFrozenToday
	}
}

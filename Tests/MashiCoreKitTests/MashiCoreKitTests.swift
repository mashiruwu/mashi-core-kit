import Foundation
import Testing
import GamificationKit

@Test func completionIsIdempotentAndFreezeRequiresAnActivePreviousDay() {
	let suite = "MashiCoreKitTests.\(UUID().uuidString)"
	let defaults = UserDefaults(suiteName: suite)!
	defer { defaults.removePersistentDomain(forName: suite) }

	var calendar = Calendar(identifier: .gregorian)
	calendar.timeZone = TimeZone(secondsFromGMT: 0)!
	let firstDay = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12))!
	let thirdDay = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 12))!
	let manager = MashiStreakManager(id: "test", defaults: defaults, calendar: calendar)

	manager.registerCompletion(now: firstDay)
	manager.registerCompletion(now: firstDay.addingTimeInterval(60))
	#expect(manager.status.count == 1)
	#expect(manager.status.hasCompletedToday)

	manager.registerFreeze(now: thirdDay)
	#expect(manager.status.count == 1)
	#expect(!manager.status.isFrozenToday)
}

@Test func freezePreservesButDoesNotIncreaseAConsecutiveStreak() {
	let suite = "MashiCoreKitTests.\(UUID().uuidString)"
	let defaults = UserDefaults(suiteName: suite)!
	defer { defaults.removePersistentDomain(forName: suite) }

	var calendar = Calendar(identifier: .gregorian)
	calendar.timeZone = TimeZone(secondsFromGMT: 0)!
	let dayOne = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12))!
	let dayTwo = calendar.date(byAdding: .day, value: 1, to: dayOne)!
	let dayThree = calendar.date(byAdding: .day, value: 1, to: dayTwo)!
	let manager = MashiStreakManager(id: "test", defaults: defaults, calendar: calendar)

	manager.registerCompletion(now: dayOne)
	manager.registerFreeze(now: dayTwo)
	#expect(manager.status.count == 1)
	#expect(manager.status.isFrozenToday)

	manager.registerCompletion(now: dayThree)
	#expect(manager.status.count == 2)
	#expect(manager.status.hasCompletedToday)
	#expect(!manager.status.isFrozenToday)
}

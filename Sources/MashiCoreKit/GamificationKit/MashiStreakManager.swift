import Foundation
import SwiftUI

public final class MashiStreakManager: ObservableObject {
	@Published public private(set) var status: MashiStreakStatus

	private let id: String
	private let defaults: UserDefaults
	private let calendar: Calendar
	
	private var streakKey: String { "mashi_streak_count_\(id)" }
	private var lastCompletionDateKey: String { "mashi_streak_last_completion_\(id)" }
	private var lastFreezeDateKey: String { "mashi_streak_last_freeze_\(id)" }

	public init(id: String = "default", defaults: UserDefaults = .standard, calendar: Calendar = .current) {
		self.id = id
		self.defaults = defaults
		self.calendar = calendar
		
		self.status = MashiStreakStatus(count: 0, hasCompletedToday: false, isFrozenToday: false)
		self.refresh()
	}

	public func registerCompletion(now: Date = Date()) {
		let today = calendar.startOfDay(for: now)
		var currentStreak = defaults.integer(forKey: streakKey)
		let lastCompletion = lastCompletionDay()
		let lastFreeze = lastFreezeDay()

		// Idempotent completion
		if let last = lastCompletion, calendar.isDate(last, inSameDayAs: today) {
			return
		}
		
		// If frozen today, we undo the freeze and mark as completed.
		// It counts as a completed day, so we increase the streak from yesterday.
		let wasFrozenToday = lastFreeze.map { calendar.isDate($0, inSameDayAs: today) } ?? false
		var newLastFreeze = lastFreeze
		if wasFrozenToday {
			newLastFreeze = nil
			// Since it was frozen, it was preventing a break, but we hadn't incremented the score. 
			// We should increment it now.
		}

		if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
			let wasCompletedYesterday = lastCompletion.map { calendar.isDate($0, inSameDayAs: yesterday) } ?? false
			let wasFrozenYesterday = lastFreeze.map { calendar.isDate($0, inSameDayAs: yesterday) } ?? false
			
			if wasCompletedYesterday || wasFrozenYesterday {
				currentStreak += 1
			} else {
				currentStreak = 1
			}
		} else {
			currentStreak = 1
		}

		save(streak: currentStreak, lastCompletion: now, lastFreeze: newLastFreeze)
		updateStatus(now: now)
	}

	public func registerFreeze(now: Date = Date()) {
		let today = calendar.startOfDay(for: now)
		let currentStreak = defaults.integer(forKey: streakKey)
		let lastCompletion = lastCompletionDay()
		let lastFreeze = lastFreezeDay()
		
		// Cannot freeze if already completed or frozen today
		if let last = lastCompletion, calendar.isDate(last, inSameDayAs: today) {
			return
		}
		if let last = lastFreeze, calendar.isDate(last, inSameDayAs: today) {
			return
		}
		
		// A freeze holds an active streak but never extends it by itself.
		guard currentStreak > 0,
			let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
			lastCompletion.map({ calendar.isDate($0, inSameDayAs: yesterday) }) == true
				|| lastFreeze.map({ calendar.isDate($0, inSameDayAs: yesterday) }) == true else { return }

		save(streak: currentStreak, lastCompletion: lastCompletion, lastFreeze: now)
		updateStatus(now: now)
	}

	public func refresh(now: Date = Date()) {
		let today = calendar.startOfDay(for: now)
		var currentStreak = defaults.integer(forKey: streakKey)
		let lastCompletion = lastCompletionDay()
		let lastFreeze = lastFreezeDay()
		
		if lastCompletion == nil && lastFreeze == nil {
			currentStreak = 0
			save(streak: 0, lastCompletion: nil, lastFreeze: nil)
			updateStatus(now: now)
			return
		}

		guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
		
		let isTodayCompleted = lastCompletion.map { calendar.isDate($0, inSameDayAs: today) } ?? false
		let isTodayFrozen = lastFreeze.map { calendar.isDate($0, inSameDayAs: today) } ?? false
		let isYesterdayCompleted = lastCompletion.map { calendar.isDate($0, inSameDayAs: yesterday) } ?? false
		let isYesterdayFrozen = lastFreeze.map { calendar.isDate($0, inSameDayAs: yesterday) } ?? false

		if !isTodayCompleted && !isTodayFrozen && !isYesterdayCompleted && !isYesterdayFrozen && currentStreak != 0 {
			currentStreak = 0
			save(streak: currentStreak, lastCompletion: lastCompletion, lastFreeze: lastFreeze)
		}
		
		updateStatus(now: now)
	}

	// MARK: Private

	private func updateStatus(now: Date) {
		let today = calendar.startOfDay(for: now)
		let count = defaults.integer(forKey: streakKey)
		let lastCompletion = lastCompletionDay()
		let lastFreeze = lastFreezeDay()
		
		let completedToday = lastCompletion.map { calendar.isDate($0, inSameDayAs: today) } ?? false
		let frozenToday = lastFreeze.map { calendar.isDate($0, inSameDayAs: today) } ?? false
		
		self.status = MashiStreakStatus(
			count: count,
			hasCompletedToday: completedToday,
			isFrozenToday: frozenToday
		)
	}

	private func lastCompletionDay() -> Date? {
		guard let date = defaults.object(forKey: lastCompletionDateKey) as? Date else { return nil }
		return calendar.startOfDay(for: date)
	}
	
	private func lastFreezeDay() -> Date? {
		guard let date = defaults.object(forKey: lastFreezeDateKey) as? Date else { return nil }
		return calendar.startOfDay(for: date)
	}

	private func save(streak: Int, lastCompletion: Date?, lastFreeze: Date?) {
		defaults.set(streak, forKey: streakKey)
		if let lastCompletion {
			defaults.set(lastCompletion, forKey: lastCompletionDateKey)
		} else {
			defaults.removeObject(forKey: lastCompletionDateKey)
		}
		
		if let lastFreeze {
			defaults.set(lastFreeze, forKey: lastFreezeDateKey)
		} else {
			defaults.removeObject(forKey: lastFreezeDateKey)
		}
	}
	
	#if DEBUG
	// Helper to simulate time travel for previews and testing
	public func _debug_reset() {
		defaults.removeObject(forKey: streakKey)
		defaults.removeObject(forKey: lastCompletionDateKey)
		defaults.removeObject(forKey: lastFreezeDateKey)
		refresh()
	}
	#endif
}

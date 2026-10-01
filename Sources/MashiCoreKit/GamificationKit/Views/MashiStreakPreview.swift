import SwiftUI

#if DEBUG
struct MashiStreakPreview_Previews: PreviewProvider {
	static var previews: some View {
		StreakDemo()
	}
}

private struct StreakDemo: View {
	@StateObject private var streakManager = MashiStreakManager(id: "preview_streak")
	
	// Simple mock time to test timezone/day changes easily
	@State private var mockDate = Date()
	
	var body: some View {
		VStack(spacing: 24) {
			Text(String(localized: "🔥 GamificationKit"))
				.font(.headline)
			
			VStack(spacing: 8) {
				Text("\(streakManager.status.count)")
					.font(.system(size: 80, weight: .bold, design: .rounded))
					.foregroundStyle(.orange)
				
				Text(String(localized: "Day Streak"))
					.font(.title2.bold())
				
				if streakManager.status.isFrozenToday {
					Text(String(localized: "❄️ Streak Frozen Today"))
						.foregroundStyle(.blue)
						.font(.subheadline.bold())
				} else if streakManager.status.hasCompletedToday {
					Text(String(localized: "✅ Completed Today"))
						.foregroundStyle(.green)
						.font(.subheadline.bold())
				} else {
					Text(String(localized: "⚠️ Not completed today"))
						.foregroundStyle(.red)
						.font(.subheadline.bold())
				}
			}
			.padding()
			.background(Color.gray.opacity(0.16))
			.cornerRadius(16)
			
			VStack(spacing: 12) {
				Button(String(localized: "Complete Task")) {
					streakManager.registerCompletion(now: mockDate)
				}
				.buttonStyle(.borderedProminent)
				.tint(.green)
				.disabled(streakManager.status.hasCompletedToday)
				
				Button(String(localized: "Use Streak Freeze ❄️")) {
					streakManager.registerFreeze(now: mockDate)
				}
				.buttonStyle(.borderedProminent)
				.tint(.blue)
				.disabled(streakManager.status.hasCompletedToday || streakManager.status.isFrozenToday)
				
				Divider().padding(.vertical)
				
				Text(String(localized: "Time Travel (Mocking)"))
					.font(.caption)
				
				Button(String(localized: "Advance to Tomorrow")) {
					mockDate = Calendar.current.date(byAdding: .day, value: 1, to: mockDate)!
					streakManager.refresh(now: mockDate)
				}
				.buttonStyle(.bordered)
				
				Button(String(localized: "Reset Data")) {
					streakManager._debug_reset()
					mockDate = Date()
				}
				.foregroundStyle(.red)
			}
			.padding(.horizontal)
		}
		.padding()
		.onAppear {
			// Clean up any stale data from previous preview runs
			streakManager.refresh(now: mockDate)
		}
	}
}
#endif

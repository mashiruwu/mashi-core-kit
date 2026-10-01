# Streaks

Product/import: `GamificationKit`. No external dependencies. iOS 16+.

Create `MashiStreakManager(id: userID)` per signed-in user, observe its `status`, call `registerCompletion()` when the user completes the daily action, and call `registerFreeze()` only when the product grants a freeze. `refresh()` recalculates whether a streak is still active.

State is local to UserDefaults on one device, not synced across devices. A freeze preserves an active streak but does not increment it. Do not use this local state for rewards or account security.

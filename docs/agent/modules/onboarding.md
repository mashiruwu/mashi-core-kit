# Onboarding

Product/import: `OnboardingKit`. No external dependencies. iOS 16+.

Build `[OnboardingPage]` with eyebrow, title, message, features, and button title. Then present `OnboardingView(pages:background:onComplete:)`. Pass your app's background as a SwiftUI view. When collecting an intent, use the initializer with `intentSelection` and provide the final selection screen yourself.

The package owns only page navigation and display; the app owns persistence of completion and any selected intent. Use stable data IDs in the host app. Do not load `OnboardingPreview.swift` into context unless you need its visual example.

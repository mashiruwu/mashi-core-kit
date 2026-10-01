import SwiftUI

#if DEBUG
struct OnboardingPreview_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingDemo()
	}
}

private struct OnboardingDemo: View {
	@State private var isFinished = false
	@State private var selectedIntent: String? = nil

	private var demoPages: [OnboardingPage] {
		[
			OnboardingPage(
				eyebrow: "Welcome",
				title: String(localized: "Reusable Module"),
				message: String(localized: "This is a generic onboarding module from MashiCoreKit."),
				previewContent: {
					OnboardingPreviewPanel {
						Image(systemName: "star.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 80, height: 80)
							.foregroundColor(.accentColor)
					}
				},
				features: [
					OnboardingFeature(systemImage: "paintbrush", title: String(localized: "Customizable"), message: String(localized: "Inject your own views and colors.")),
					OnboardingFeature(systemImage: "arrow.right.circle", title: String(localized: "Configurable Flow"), message: String(localized: "Pass any number of pages."))
				],
				primaryButtonTitle: "Continue"
			),
			OnboardingPage(
				eyebrow: "Second Step",
				title: String(localized: "Keep learning"),
				message: String(localized: "Add as many steps as you need."),
				features: [
					OnboardingFeature(systemImage: "bolt.fill", title: String(localized: "Fast"), message: "Loads quickly.")
				],
				primaryButtonTitle: "Personalize"
			)
		]
	}

	private var intents: [OnboardingIntent] {
		[
			OnboardingIntent(id: "1", title: String(localized: "Option 1"), message: String(localized: "First choice"), systemImage: "1.circle.fill"),
			OnboardingIntent(id: "2", title: String(localized: "Option 2"), message: String(localized: "Second choice"), systemImage: "2.circle.fill")
		]
	}

	var body: some View {
		if isFinished {
			Text(String(localized: "Onboarding Complete!"))
				.font(.title)
				.bold()
		} else {
			OnboardingView(
				pages: demoPages,
				background: {
					LinearGradient(
						colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				},
				intentSelection: {
					OnboardingIntentSelectionView(
						page: 3,
						totalPages: 3,
						eyebrow: "Personalize",
						title: String(localized: "Choose an option"),
						message: String(localized: "Select your intent below."),
						intents: intents,
						selectedIntentId: $selectedIntent,
						onContinue: {
							isFinished = true
						}
					)
				},
				onComplete: {
					isFinished = true
				}
			)
			.tint(.orange)
		}
	}
}
#endif

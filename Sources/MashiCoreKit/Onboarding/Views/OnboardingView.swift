import SwiftUI

public struct OnboardingView<Background: View, IntentSelection: View>: View {
	public let pages: [OnboardingPage]
	public let background: Background
	@ViewBuilder public let intentSelection: IntentSelection
	public let onComplete: () -> Void

	@State private var path = NavigationPath()
	
	public init(
		pages: [OnboardingPage],
		@ViewBuilder background: () -> Background,
		@ViewBuilder intentSelection: () -> IntentSelection,
		onComplete: @escaping () -> Void
	) {
		self.pages = pages
		self.background = background()
		self.intentSelection = intentSelection()
		self.onComplete = onComplete
	}
	
	// Convenience init without intent selection
	public init(
		pages: [OnboardingPage],
		@ViewBuilder background: () -> Background,
		onComplete: @escaping () -> Void
	) where IntentSelection == EmptyView {
		self.pages = pages
		self.background = background()
		self.intentSelection = EmptyView()
		self.onComplete = onComplete
	}

	private var totalSteps: Int {
		pages.count + (IntentSelection.self != EmptyView.self ? 1 : 0)
	}

	public var body: some View {
		NavigationStack(path: $path) {
			viewForStep(0)
				.navigationDestination(for: Int.self) { stepIndex in
					viewForStep(stepIndex)
				}
		}
		.preferredColorScheme(.dark)
	}
	
	@ViewBuilder
	private func viewForStep(_ index: Int) -> some View {
		ZStack {
			background
				.ignoresSafeArea()
			
			if index < pages.count {
				OnboardingPageView(
					pageIndex: index,
					totalPages: totalSteps,
					page: pages[index]
				) {
					if index < totalSteps - 1 {
						path.append(index + 1)
					} else {
						onComplete()
					}
				}
			} else if IntentSelection.self != EmptyView.self {
				intentSelection
			}
		}
#if os(iOS)
		.toolbar(.hidden, for: .navigationBar)
		.navigationBarBackButtonHidden()
#endif
	}
}

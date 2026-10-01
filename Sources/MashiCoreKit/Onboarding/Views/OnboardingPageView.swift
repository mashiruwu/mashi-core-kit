import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct OnboardingPageView: View {
	public let pageIndex: Int
	public let totalPages: Int
	public let page: OnboardingPage
	public let onContinue: () -> Void

	public init(pageIndex: Int, totalPages: Int, page: OnboardingPage, onContinue: @escaping () -> Void) {
		self.pageIndex = pageIndex
		self.totalPages = totalPages
		self.page = page
		self.onContinue = onContinue
	}

	public var body: some View {
		VStack(spacing: 0) {
			OnboardingPageHeader(
				page: pageIndex + 1,
				totalPages: totalPages,
				eyebrow: page.eyebrow,
				title: page.title,
				message: page.message
			)

			Spacer(minLength: 8)

			if let previewContent = page.previewContent {
				previewContent
				Spacer(minLength: 8)
			}

			if !page.features.isEmpty {
				VStack(spacing: 8) {
					ForEach(page.features) { feature in
						OnboardingFeatureRow(feature: feature)
					}
				}
				Spacer(minLength: 12)
			}

			OnboardingPrimaryButton(
				title: page.primaryButtonTitle,
				systemImage: page.primaryButtonSystemImage
			) {
				#if os(iOS)
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				#endif
				
				if let customAction = page.customAction {
					customAction()
				} else {
					onContinue()
				}
			}
		}
		.padding(.horizontal, 20)
		.padding(.top, 12)
		.padding(.bottom, 10)
	}
}

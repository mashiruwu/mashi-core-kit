import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct OnboardingIntentSelectionView: View {
	public let page: Int
	public let totalPages: Int
	public let eyebrow: String
	public let title: String
	public let message: String
	public let intents: [OnboardingIntent]
	public let buttonTitle: String
	
	@Binding public var selectedIntentId: String?
	public let onContinue: () -> Void

	public init(
		page: Int,
		totalPages: Int,
		eyebrow: String,
		title: String,
		message: String,
		intents: [OnboardingIntent],
		buttonTitle: String = "Continue",
		selectedIntentId: Binding<String?>,
		onContinue: @escaping () -> Void
	) {
		self.page = page
		self.totalPages = totalPages
		self.eyebrow = eyebrow
		self.title = title
		self.message = message
		self.intents = intents
		self.buttonTitle = buttonTitle
		self._selectedIntentId = selectedIntentId
		self.onContinue = onContinue
	}

	public var body: some View {
		VStack(spacing: 0) {
			OnboardingPageHeader(
				page: page,
				totalPages: totalPages,
				eyebrow: eyebrow,
				title: title,
				message: message
			)

			Spacer(minLength: 12)

			VStack(spacing: 9) {
				ForEach(intents) { intent in
					intentButton(intent)
				}
			}

			Spacer(minLength: 12)

			OnboardingPrimaryButton(
				title: selectedIntentId == nil ? "Choose an option" : buttonTitle,
				systemImage: selectedIntentId == nil ? "circle.dashed" : "arrow.right"
			) {
				#if os(iOS)
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				#endif
				onContinue()
			}
			.disabled(selectedIntentId == nil)
			.opacity(selectedIntentId == nil ? 0.55 : 1)
		}
		.padding(.horizontal, 20)
		.padding(.top, 12)
		.padding(.bottom, 10)
	}

	private func intentButton(_ intent: OnboardingIntent) -> some View {
		let isSelected = selectedIntentId == intent.id

		return Button {
			#if os(iOS)
			UISelectionFeedbackGenerator().selectionChanged()
			#endif
			withAnimation(.easeInOut(duration: 0.18)) {
				selectedIntentId = intent.id
			}
		} label: {
			HStack(spacing: 11) {
				Image(systemName: intent.systemImage)
					.font(.system(size: 16, weight: .semibold))
					.foregroundStyle(isSelected ? .white : Color.accentColor)
					.frame(width: 34, height: 34)
					.background(
						isSelected ? Color.white.opacity(0.2) : Color.accentColor.opacity(0.22),
						in: Circle()
					)

				VStack(alignment: .leading, spacing: 2) {
					Text(intent.title)
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(.white)
					Text(intent.message)
						.font(.caption2)
						.foregroundStyle(.white.opacity(0.85))
						.lineLimit(1)
				}

				Spacer(minLength: 6)

				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.font(.title3)
					.foregroundStyle(isSelected ? .white : .white.opacity(0.55))
			}
			.padding(.horizontal, 13)
			.frame(minHeight: 62)
			.background(
				isSelected ? Color.accentColor.opacity(0.82) : Color.black.opacity(0.42),
				in: RoundedRectangle(cornerRadius: 15, style: .continuous)
			)
			.overlay {
				RoundedRectangle(cornerRadius: 15, style: .continuous)
					.stroke(
						isSelected ? .white.opacity(0.55) : .white.opacity(0.28),
						lineWidth: 1
					)
			}
			.shadow(color: .black.opacity(0.2), radius: 8, y: 3)
		}
		.buttonStyle(.plain)
		.accessibilityValue(isSelected ? "Selected" : "Not selected")
	}
}

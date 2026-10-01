import SwiftUI

public struct OnboardingPageHeader: View {
	public let page: Int
	public let totalPages: Int
	public let eyebrow: String
	public let title: String
	public let message: String

	public init(page: Int, totalPages: Int, eyebrow: String, title: String, message: String) {
		self.page = page
		self.totalPages = totalPages
		self.eyebrow = eyebrow
		self.title = title
		self.message = message
	}

	public var body: some View {
		VStack(spacing: 9) {
			HStack(spacing: 7) {
				ForEach(1...max(1, totalPages), id: \.self) { index in
					Capsule()
						.fill(index == page ? Color.accentColor : .white.opacity(0.2))
						.frame(width: index == page ? 28 : 8, height: 8)
				}
			}
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Step \(page) of \(totalPages)")

			Text(eyebrow.uppercased())
				.font(.caption.weight(.bold))
				.tracking(1.2)
				.foregroundStyle(Color.accentColor)

			Text(title)
				.font(.system(.title, design: .rounded, weight: .bold))
				.foregroundStyle(.white)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)

			Text(message)
				.font(.subheadline)
				.foregroundStyle(.white.opacity(0.88))
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding(.horizontal, 20)
	}
}

public struct OnboardingFeatureRow: View {
	public let feature: OnboardingFeature

	public init(feature: OnboardingFeature) {
		self.feature = feature
	}

	public var body: some View {
		HStack(alignment: .center, spacing: 12) {
			Image(systemName: feature.systemImage)
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.accentColor)
				.frame(width: 32, height: 32)
				.background(Color.accentColor.opacity(0.14), in: Circle())

			VStack(alignment: .leading, spacing: 3) {
				Text(feature.title)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.white)
				Text(feature.message)
					.font(.caption)
					.foregroundStyle(.white.opacity(0.82))
					.fixedSize(horizontal: false, vertical: true)
			}

			Spacer(minLength: 0)
		}
		.padding(.vertical, 3)
		.accessibilityElement(children: .combine)
	}
}

public struct OnboardingPreviewPanel<Content: View>: View {
	@ViewBuilder public let content: Content

	public init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	public var body: some View {
		content
			.padding(14)
			.background(Color.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.stroke(.white.opacity(0.28), lineWidth: 1)
			}
			.shadow(color: .black.opacity(0.25), radius: 10, y: 4)
	}
}

public struct OnboardingPrimaryButton: View {
	public let title: String
	public var systemImage: String
	public let action: () -> Void

	public init(title: String, systemImage: String = "arrow.right", action: @escaping () -> Void) {
		self.title = title
		self.systemImage = systemImage
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			HStack {
				Text(title)
				Spacer()
				if !systemImage.isEmpty {
					Image(systemName: systemImage)
				}
			}
			.font(.headline)
			.foregroundStyle(.white)
			.padding(.horizontal, 18)
			.frame(maxWidth: .infinity, minHeight: 50)
			.background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
		}
		.buttonStyle(.plain)
		.accessibilityHint(String(localized: "Continues to the next onboarding step"))
	}
}

import SwiftUI

public struct OnboardingPage: Identifiable {
	public let id = UUID()
	public let eyebrow: String
	public let title: String
	public let message: String
	public let previewContent: AnyView?
	public let features: [OnboardingFeature]
	public let primaryButtonTitle: String
	public let primaryButtonSystemImage: String
	public let customAction: (() -> Void)?

	public init<Content: View>(
		eyebrow: String,
		title: String,
		message: String,
		@ViewBuilder previewContent: () -> Content,
		features: [OnboardingFeature],
		primaryButtonTitle: String,
		primaryButtonSystemImage: String = "arrow.right",
		customAction: (() -> Void)? = nil
	) {
		self.eyebrow = eyebrow
		self.title = title
		self.message = message
		if Content.self != EmptyView.self {
			self.previewContent = AnyView(previewContent())
		} else {
			self.previewContent = nil
		}
		self.features = features
		self.primaryButtonTitle = primaryButtonTitle
		self.primaryButtonSystemImage = primaryButtonSystemImage
		self.customAction = customAction
	}
	
	public init(
		eyebrow: String,
		title: String,
		message: String,
		features: [OnboardingFeature],
		primaryButtonTitle: String,
		primaryButtonSystemImage: String = "arrow.right",
		customAction: (() -> Void)? = nil
	) {
		self.eyebrow = eyebrow
		self.title = title
		self.message = message
		self.previewContent = nil
		self.features = features
		self.primaryButtonTitle = primaryButtonTitle
		self.primaryButtonSystemImage = primaryButtonSystemImage
		self.customAction = customAction
	}
}

public struct OnboardingFeature: Identifiable {
	public let id = UUID()
	public let systemImage: String
	public let title: String
	public let message: String

	public init(systemImage: String, title: String, message: String) {
		self.systemImage = systemImage
		self.title = title
		self.message = message
	}
}

public struct OnboardingIntent: Identifiable, Equatable {
	public let id: String
	public let title: String
	public let message: String
	public let systemImage: String

	public init(id: String, title: String, message: String, systemImage: String) {
		self.id = id
		self.title = title
		self.message = message
		self.systemImage = systemImage
	}
}

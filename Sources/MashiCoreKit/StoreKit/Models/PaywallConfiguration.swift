import Foundation

public struct PaywallConfiguration {
	public let heroTitle: String
	public let heroSubtitle: String
	public let features: [String]
	public let privacyURL: URL?
	public let termsURL: URL?
	public let supportURL: URL?
	
	public init(
		heroTitle: String,
		heroSubtitle: String,
		features: [String],
		privacyURL: URL? = nil,
		termsURL: URL? = nil,
		supportURL: URL? = nil
	) {
		self.heroTitle = heroTitle
		self.heroSubtitle = heroSubtitle
		self.features = features
		self.privacyURL = privacyURL
		self.termsURL = termsURL
		self.supportURL = supportURL
	}
}

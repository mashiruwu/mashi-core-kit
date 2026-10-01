import StoreKit
import SwiftUI

#if DEBUG
struct MashiPaywallView_Previews: PreviewProvider {
	static var previews: some View {
		PaywallDemo()
	}
}

private struct PaywallDemo: View {
	@StateObject private var entitlementManager = MashiEntitlementManager()
	@StateObject private var subscriptionsManager: MashiSubscriptionsManager

	init() {
		let entitlement = MashiEntitlementManager()
		_entitlementManager = StateObject(wrappedValue: entitlement)
		_subscriptionsManager = StateObject(
			wrappedValue: MashiSubscriptionsManager(
				productIDs: ["com.example.pro.monthly", "com.example.pro.yearly"],
				entitlementManager: entitlement
			)
		)
	}

	var body: some View {
		MashiPaywallView(
			subscriptions: subscriptionsManager,
			entitlementManager: entitlementManager,
			configuration: PaywallConfiguration(
				heroTitle: "Unlock Pro Features",
				heroSubtitle: String(localized: "Get access to unlimited magic and power."),
				features: [
					"Unlimited generation of magic items",
					"Ad-free experience forever",
					"Priority support via email"
				],
				privacyURL: URL(string: "https://example.com/privacy"),
				termsURL: URL(string: "https://example.com/terms"),
				supportURL: URL(string: "https://example.com/support")
			),
			onTrackEvent: { event, params in
				print("Event: \(event), Params: \(params)")
			},
			onClose: {
				print("Close button tapped")
			}
		)
	}
}
#endif

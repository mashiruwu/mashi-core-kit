import StoreKit
import SwiftUI

@MainActor
public final class MashiPaywallViewModel: ObservableObject {
	@Published public var selectedProduct: Product?
	@Published public var isLoading = false
	@Published public var isLoadingProducts = false
	@Published public var isRestoring = false
	@Published public var productLoadError: String?
	@Published public var purchaseMessage: String?

	public init() {}

	public func anyProductHasFreeTrial(in products: [Product]) -> Bool {
		products.contains(where: hasFreeTrial)
	}

	public func selectedHasFreeTrial() -> Bool {
		selectedProduct.map(hasFreeTrial) ?? false
	}

	public func recommendedProductID(in products: [Product]) -> String? {
		products.first(where: { $0.subscription?.subscriptionPeriod.unit == .year })?.id
	}

	public func savingsPercent(for product: Product, in products: [Product]) -> Int? {
		guard product.subscription?.subscriptionPeriod.unit == .year,
			let monthly = products.first(where: { $0.subscription?.subscriptionPeriod.unit == .month }) else {
			return nil
		}
		let yearlyFromMonthly = NSDecimalNumber(decimal: monthly.price).doubleValue * 12
		let annual = NSDecimalNumber(decimal: product.price).doubleValue
		guard yearlyFromMonthly > annual else { return nil }
		return Int(((yearlyFromMonthly - annual) / yearlyFromMonthly * 100).rounded())
	}

	public func loadProducts(using subscriptions: MashiSubscriptionsManager) async {
		isLoadingProducts = true
		productLoadError = nil
		defer { isLoadingProducts = false }

		productLoadError = await subscriptions.loadProducts()
		if !subscriptions.products.contains(where: { $0.id == selectedProduct?.id }) {
			selectedProduct = subscriptions.products.first(where: { $0.id == recommendedProductID(in: subscriptions.products) }) ?? subscriptions.products.first
		}
	}

	public func buySelected(
		using subscriptions: MashiSubscriptionsManager,
		onPurchased: @escaping @MainActor () -> Void
	) async -> String {
		guard let selectedProduct else { return "no_selection" }
		isLoading = true
		purchaseMessage = nil
		defer { isLoading = false }

		switch await subscriptions.buyProduct(selectedProduct) {
		case .purchased:
			onPurchased()
			return "purchased"
		case .userCancelled:
			return "cancelled"
		case .pending:
			purchaseMessage = "Your purchase is pending approval. Premium will unlock automatically when it completes."
			return "pending"
		case let .unverified(error):
			purchaseMessage = "The purchase completed, but StoreKit could not verify it for this device. Please reset the StoreKit test transactions and try again.\n\n\(error)"
			return "unverified"
		case let .failed(error):
			purchaseMessage = "The purchase could not be completed. Please try again.\n\n\(error)"
			return "failed"
		}
	}

	public func restore(using subscriptions: MashiSubscriptionsManager) async -> String {
		isRestoring = true
		purchaseMessage = nil
		defer { isRestoring = false }

		if let error = await subscriptions.restorePurchases() {
			purchaseMessage = "Purchases could not be restored.\n\n\(error)"
			return "failed"
		} else if subscriptions.purchasedProductIDs.isEmpty {
			purchaseMessage = "No previous Premium purchase was found for this App Store account."
			return "not_found"
		} else {
			purchaseMessage = "Your Premium purchase was restored."
			return "restored"
		}
	}

	public func hasFreeTrial(_ product: Product) -> Bool {
		product.subscription?.introductoryOffer?.paymentMode == .freeTrial
	}
}

import StoreKit
import SwiftUI

public enum PurchaseOutcome {
	case purchased
	case userCancelled
	case pending
	case unverified(String)
	case failed(String)
}

@MainActor
public final class MashiSubscriptionsManager: NSObject, ObservableObject {
	public let productIDs: [String]
	@Published public private(set) var purchasedProductIDs: Set<String> = []
	@Published public var products: [Product] = []

	private weak var entitlementManager: MashiEntitlementManager?
	private let appAccountTokenProvider: (() async throws -> UUID)?
	private var updates: Task<Void, Never>?

	public init(
		productIDs: [String],
		entitlementManager: MashiEntitlementManager,
		appAccountTokenProvider: (() async throws -> UUID)? = nil
	) {
		self.productIDs = productIDs
		self.entitlementManager = entitlementManager
		self.appAccountTokenProvider = appAccountTokenProvider
		super.init()
		self.updates = observeTransactionUpdates()
	}

	deinit {
		updates?.cancel()
	}

	private func observeTransactionUpdates() -> Task<Void, Never> {
		Task(priority: .background) { [weak self] in
			for await result in Transaction.updates {
				guard let self else { return }
				guard case let .verified(transaction) = result,
					self.productIDs.contains(transaction.productID) else {
					continue
				}
				await self.updatePurchasedProducts()
				await transaction.finish()
			}
		}
	}

	public func loadProducts() async -> String? {
		do {
			products = try await Product.products(for: productIDs)
				.sorted(by: { $0.price > $1.price })
			return products.isEmpty ? "No subscription plans are currently available." : nil
		} catch {
			products = []
			return error.localizedDescription
		}
	}

	public func buyProduct(_ product: Product) async -> PurchaseOutcome {
		do {
			var options: Set<Product.PurchaseOption> = []
			if let provider = appAccountTokenProvider {
				let token = try await provider()
				options.insert(.appAccountToken(token))
			}
			let result = try await product.purchase(options: options)

			switch result {
			case let .success(.verified(transaction)):
				await transaction.finish()
				await updatePurchasedProducts()
				return .purchased
			case let .success(.unverified(_, error)):
				return .unverified(String(describing: error))
			case .pending:
				return .pending
			case .userCancelled:
				return .userCancelled
			@unknown default:
				return .failed("StoreKit returned an unknown purchase result.")
			}
		} catch {
			return .failed(error.localizedDescription)
		}
	}

	public func updatePurchasedProducts() async {
		var activeTransactions: [StoreKit.Transaction] = []

		for await result in StoreKit.Transaction.currentEntitlements {
			guard case let .verified(transaction) = result,
				productIDs.contains(transaction.productID),
				transaction.revocationDate == nil,
				transaction.expirationDate.map({ $0 > Date() }) ?? true else {
				continue
			}
			activeTransactions.append(transaction)
		}

		purchasedProductIDs = Set(activeTransactions.map(\.productID))
		entitlementManager?.hasPro = !activeTransactions.isEmpty
	}

	public func restorePurchases() async -> String? {
		do {
			try await AppStore.sync()
			await updatePurchasedProducts()
			return nil
		} catch {
			return error.localizedDescription
		}
	}
}

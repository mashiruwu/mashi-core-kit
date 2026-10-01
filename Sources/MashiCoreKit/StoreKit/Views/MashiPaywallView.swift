import StoreKit
import SwiftUI

public struct MashiPaywallView: View {
	@ObservedObject private var subscriptions: MashiSubscriptionsManager
	@ObservedObject private var entitlementManager: MashiEntitlementManager
	
	@StateObject private var viewModel = MashiPaywallViewModel()
	@State private var showManageSubscriptions = false
	
	public let configuration: PaywallConfiguration
	public let onTrackEvent: ((String, [String: Any]) -> Void)?
	public let onClose: (() -> Void)

	public init(
		subscriptions: MashiSubscriptionsManager,
		entitlementManager: MashiEntitlementManager,
		configuration: PaywallConfiguration,
		onTrackEvent: ((String, [String: Any]) -> Void)? = nil,
		onClose: @escaping () -> Void
	) {
		self.subscriptions = subscriptions
		self.entitlementManager = entitlementManager
		self.configuration = configuration
		self.onTrackEvent = onTrackEvent
		self.onClose = onClose
	}

	public var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				HStack {
					Spacer()
					Button { handleDismiss() } label: {
						Image(systemName: "xmark.circle.fill")
							.font(.title2)
							.foregroundStyle(.white.opacity(0.9))
					}
				}

				hero
				featureList
				productList
				purchaseActions

				legalLinks
			}
			.padding(.horizontal)
			.padding(.bottom, 24)
			.animation(.easeInOut, value: viewModel.isLoadingProducts)
		}
		.task {
			await viewModel.loadProducts(using: subscriptions)
		}
		.onAppear { onTrackEvent?("paywall_viewed", [:]) }
		.alert(
			"Purchase Status",
			isPresented: Binding(
				get: { viewModel.purchaseMessage != nil },
				set: { if !$0 { viewModel.purchaseMessage = nil } }
			)
		) {
			Button(String(localized: "OK"), role: .cancel) {
				viewModel.purchaseMessage = nil
			}
		} message: {
			Text(viewModel.purchaseMessage ?? "")
		}
#if os(iOS)
		.manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
#endif
		.background { Color.black.ignoresSafeArea() }
		.preferredColorScheme(.dark)
	}

	private func handleDismiss() {
		onTrackEvent?("paywall_dismissed", [:])
		onClose()
	}

	private var hero: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 20)
				.fill(
					LinearGradient(
						colors: [.blue.opacity(0.9), .purple.opacity(0.9)],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
				.shadow(radius: 10, y: 6)

			HStack(spacing: 14) {
				Image(systemName: "lock.fill")
					.font(.system(size: 42, weight: .bold))
				VStack(alignment: .leading, spacing: 4) {
					Text(configuration.heroTitle).font(.title.bold())
					Text(configuration.heroSubtitle)
						.font(.subheadline)
						.opacity(0.9)
				}
				Spacer()
			}
			.foregroundStyle(.white)
			.padding()
		}
		.frame(maxWidth: .infinity, minHeight: 110)
	}

	private var featureList: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(String(localized: "What you get")).font(.headline)
			ForEach(configuration.features, id: \.self) { feature in
				HStack(spacing: 12) {
					Image(systemName: "sparkles")
					Text(feature).font(.subheadline)
					Spacer()
				}
				.padding(12)
				.background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
			}
		}
		.foregroundStyle(.white)
	}

	private var productList: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(String(localized: "Choose your plan"))
				.font(.headline)
				.foregroundStyle(.white)

			if viewModel.isLoadingProducts {
				HStack {
					ProgressView()
					Text(String(localized: "Loading plans..."))
				}
				.padding()
			} else if let error = viewModel.productLoadError {
				VStack(spacing: 10) {
					Text(error)
						.font(.footnote)
						.foregroundStyle(.white.opacity(0.8))
						.multilineTextAlignment(.center)
					Button(String(localized: "Try again")) {
						Task { await viewModel.loadProducts(using: subscriptions) }
					}
					.buttonStyle(.bordered)
				}
				.frame(maxWidth: .infinity)
				.padding()
			} else {
				ForEach(subscriptions.products, id: \.self) { product in
					MashiProductRow(
						product: product,
						selected: viewModel.selectedProduct == product,
						hasFreeTrial: viewModel.hasFreeTrial(product),
						isRecommended: viewModel.recommendedProductID(in: subscriptions.products) == product.id,
						savingsPercent: viewModel.savingsPercent(for: product, in: subscriptions.products)
					)
					.onTapGesture {
						withAnimation(.easeInOut(duration: 0.2)) {
							viewModel.selectedProduct = product
							onTrackEvent?("paywall_plan_selected", ["productID": product.id])
						}
					}
				}
			}
		}
	}

	private var purchaseActions: some View {
		VStack(spacing: 12) {
			Button {
				Task {
					onTrackEvent?("paywall_purchase_started", ["productID": viewModel.selectedProduct?.id ?? "unknown"])
					let result = await viewModel.buySelected(using: subscriptions) {
						handleDismiss()
					}
					onTrackEvent?("paywall_purchase_result", ["result": result, "productID": viewModel.selectedProduct?.id ?? "unknown"])
				}
			} label: {
				HStack {
					Text(viewModel.isLoading
						? "Loading..."
						: (viewModel.selectedHasFreeTrial() ? "Start free trial" : "Buy Now"))
						.fontWeight(.semibold)
					if viewModel.isLoading { ProgressView() }
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.white, in: RoundedRectangle(cornerRadius: 12))
				.foregroundStyle(.black)
			}
			.disabled(viewModel.selectedProduct == nil || viewModel.isLoading)

			Button {
				Task {
					let result = await viewModel.restore(using: subscriptions)
					onTrackEvent?("paywall_restore_result", ["result": result])
				}
			} label: {
				HStack {
					if viewModel.isRestoring { ProgressView() }
					Text(String(localized: "Restore purchases"))
				}
				.frame(maxWidth: .infinity, minHeight: 44)
			}
			.font(.footnote.weight(.semibold))
			.overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.35)))
			.foregroundStyle(.white)
			.disabled(viewModel.isRestoring || viewModel.isLoading)

			Button(entitlementManager.hasPro ? "Manage current subscription" : "Manage App Store subscriptions") {
				showManageSubscriptions = true
			}
			.font(.footnote.weight(.semibold))
			.foregroundStyle(.white.opacity(0.9))
		}
	}

	@ViewBuilder
	private var legalLinks: some View {
		HStack(spacing: 14) {
			if let url = configuration.privacyURL {
				Link("Privacy", destination: url)
			}
			if let url = configuration.termsURL {
				Link("Terms", destination: url)
			}
			if let url = configuration.supportURL {
				Link("Support", destination: url)
			}
		}
		.font(.footnote)
		.underline()
		.foregroundStyle(.white.opacity(0.9))
		.padding(.top, 8)
	}
}

private struct MashiProductRow: View {
	let product: Product
	let selected: Bool
	let hasFreeTrial: Bool
	let isRecommended: Bool
	let savingsPercent: Int?

	private var billingDescription: String {
		guard let period = product.subscription?.subscriptionPeriod else {
			return product.displayPrice
		}

		let unit = period.value == 1 ? singularUnitName(for: period.unit) : pluralUnitName(for: period.unit)
		return period.value == 1
			? "\(product.displayPrice) per \(unit)"
			: "\(product.displayPrice) every \(period.value) \(unit)"
	}

	private var freeTrialDescription: String? {
		guard hasFreeTrial,
			let period = product.subscription?.introductoryOffer?.period else {
			return nil
		}
		let unit = period.value == 1 ? singularUnitName(for: period.unit) : pluralUnitName(for: period.unit)
		return period.value == 1 ? "1 \(unit)" : "\(period.value) \(unit)"
	}

	var body: some View {
		HStack(spacing: 12) {
			VStack(alignment: .leading, spacing: 2) {
				HStack(spacing: 8) {
					Text(product.displayName).font(.subheadline.bold())
					if isRecommended {
						Text(String(localized: "BEST VALUE"))
							.font(.caption2.bold())
							.padding(.horizontal, 7)
							.padding(.vertical, 3)
							.background(.blue, in: Capsule())
					}
					if let savingsPercent {
						Text("SAVE \(savingsPercent)%")
							.font(.caption2.bold())
							.foregroundStyle(.green)
					}
				}
				Text(freeTrialDescription.map {
					"Free for \($0), then \(billingDescription). Auto-renews until canceled."
				} ?? "Get full access for \(billingDescription)")
					.font(.footnote)
					.opacity(0.9)
			}
			Spacer()
			Image(systemName: selected ? "largecircle.fill.circle" : "circle")
		}
		.foregroundStyle(.white)
		.padding(14)
		.background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
		.overlay(
			RoundedRectangle(cornerRadius: 14)
				.stroke(selected ? .white : .white.opacity(0.25), lineWidth: selected ? 1.2 : 0.8)
		)
	}

	private func singularUnitName(for unit: Product.SubscriptionPeriod.Unit) -> String {
		switch unit {
		case .day: return "day"
		case .week: return "week"
		case .month: return "month"
		case .year: return "year"
		@unknown default: return "period"
		}
	}

	private func pluralUnitName(for unit: Product.SubscriptionPeriod.Unit) -> String {
		switch unit {
		case .day: return "days"
		case .week: return "weeks"
		case .month: return "months"
		case .year: return "years"
		@unknown default: return "periods"
		}
	}
}

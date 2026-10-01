# StoreKit Subscriptions

Product/import: `SubscriptionsKit`. No external package dependency. iOS 16+.

Create `MashiEntitlementManager` and `MashiSubscriptionsManager(productIDs:entitlementManager:)` with the exact App Store Connect product IDs. Call `loadProducts()` to populate the paywall and `updatePurchasedProducts()` at app launch. Use `buyProduct(_:)` and `restorePurchases()` and handle every outcome, including pending and unverified.

The app must configure StoreKit products, agreements, and sandbox testers. `hasPro` persists a local UI cache only. Reconcile verified StoreKit entitlements and do not use UserDefaults as authorization for server resources. Product IDs shown in previews are examples only.

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "MashiCoreKit",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v16),
		.macOS(.v13),
	],
	products: [
		.library(name: "MashiCoreKit", targets: ["MashiCoreKit"]),
		.library(name: "AIKit", targets: ["AIKit"]),
		.library(name: "AuthKit", targets: ["AuthKit"]),
		.library(name: "DatabaseKit", targets: ["DatabaseKit"]),
		.library(name: "GamificationKit", targets: ["GamificationKit"]),
		.library(name: "OnboardingKit", targets: ["OnboardingKit"]),
		.library(name: "StorageKit", targets: ["StorageKit"]),
		.library(name: "SubscriptionsKit", targets: ["SubscriptionsKit"]),
		.library(name: "SplashScreenKit", targets: ["SplashScreenKit"]),
	],
	dependencies: [
		.package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
	],
	targets: [
		.target(name: "AIKit", path: "Sources/MashiCoreKit/AIKit"),
		.target(
			name: "AuthKit",
			dependencies: [.product(name: "Supabase", package: "supabase-swift")],
			path: "Sources/MashiCoreKit/AuthKit"
		),
		.target(
			name: "DatabaseKit",
			dependencies: ["AuthKit", .product(name: "Supabase", package: "supabase-swift")],
			path: "Sources/MashiCoreKit/DatabaseKit"
		),
		.target(name: "GamificationKit", path: "Sources/MashiCoreKit/GamificationKit"),
		.target(name: "OnboardingKit", path: "Sources/MashiCoreKit/Onboarding"),
		.target(name: "StorageKit", path: "Sources/MashiCoreKit/StorageKit"),
		.target(name: "SubscriptionsKit", path: "Sources/MashiCoreKit/StoreKit"),
		.target(name: "SplashScreenKit", path: "Sources/MashiCoreKit/SplashScreen"),
		.target(
			name: "MashiCoreKit",
			dependencies: ["AIKit", "AuthKit", "DatabaseKit", "GamificationKit", "OnboardingKit", "StorageKit", "SubscriptionsKit", "SplashScreenKit"],
			path: "Sources/MashiCoreKit/CoreKit"
		),
		.testTarget(name: "MashiCoreKitTests", dependencies: ["MashiCoreKit", "GamificationKit"]),
	]
)

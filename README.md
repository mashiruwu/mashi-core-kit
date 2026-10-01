# MashiCoreKit

A collection of small SwiftUI and app-infrastructure libraries. Import only the products a project needs; the umbrella `MashiCoreKit` product remains available for existing consumers.

## Requirements

- iOS 16 or later; macOS 13 or later for package tooling/tests.
- Swift 6.2 / Xcode 26. The package manifest uses Swift tools 6.2.
- Supabase Swift 2.x is required only by `AuthKit` and `DatabaseKit`.

## Add to an app

In Xcode, choose **File → Add Package Dependencies → Add Local…** and select this package folder. For generated projects, add the folder as a local Swift package and choose the product that matches the feature. This release is a local Swift package; it is not published as a remote Git dependency yet.

| Product | Import | External dependency | Use it for |
|---|---|---|---|
| `AIKit` | `AIKit` | None | Basic OpenAI Chat Completions client; development use only |
| `AuthKit` | `AuthKit` | Supabase Swift | Supabase email/password and Apple sign-in service |
| `DatabaseKit` | `DatabaseKit` | Supabase Swift + AuthKit | Generic Supabase repository |
| `GamificationKit` | `GamificationKit` | None | Local streak counter and streak status |
| `OnboardingKit` | `OnboardingKit` | None | Configurable SwiftUI onboarding pages |
| `StorageKit` | `StorageKit` | None | Codable values in UserDefaults / AppStorage |
| `SubscriptionsKit` | `SubscriptionsKit` | None | StoreKit subscriptions and paywall UI |
| `SplashScreenKit` | `SplashScreenKit` | None | Configurable SwiftUI splash screen |

## Quick start

Add only the required package product in Xcode. Then import its product module in the Swift file that uses it, for example:

```swift
import OnboardingKit

OnboardingView(pages: pages, background: { Color.black }) {
    hasCompletedOnboarding = true
}
```

A compact, AI-oriented entry point and individual recipes are in [`docs/agent/AI.md`](docs/agent/AI.md). Read that guide first, then only the relevant module guide. The guides intentionally keep integration instructions shorter than loading every source file into an AI context.

## Important integration notes

- Never ship an OpenAI API key in an iOS app. `AIKit` calls OpenAI directly and reads a key from app configuration; use a backend proxy in a real app.
- Supabase client apps should use the publishable/anon key and database RLS. Never pass a service-role key to these clients.
- Configure the Apple developer capability, Supabase Apple provider, product IDs, StoreKit settings, and host app image assets before using those features.
- `MashiEntitlementManager.hasPro` is a local display cache, not proof of purchase. Reconcile StoreKit entitlements at launch and gate server-side resources using verified transactions.

## Verification

Run `swift test` from this folder with Swift 6.2 / Xcode 26 installed. The published package should be validated against a real iOS simulator build as part of an app integration because local package tests alone do not prove host asset, Apple capability, Supabase RLS, or App Store configuration.

# MashiCoreKit — agent entry point

Use this package only for native iOS / SwiftUI work. It is a Swift 6.2 package targeting iOS 16+. Select the smallest product below and add that product to the Xcode project; do not paste the whole package into an app.

| Need | Product to import | Read this guide |
|---|---|---|
| Onboarding screens | `OnboardingKit` | `modules/onboarding.md` |
| Codable local preferences | `StorageKit` | `modules/storage.md` |
| Supabase login | `AuthKit` | `modules/auth.md` |
| Supabase table access | `DatabaseKit` | `modules/database.md` |
| StoreKit subscription/paywall | `SubscriptionsKit` | `modules/storekit.md` |
| Local streaks | `GamificationKit` | `modules/gamification.md` |
| Splash screen | `SplashScreenKit` | `modules/splash.md` |
| OpenAI Chat Completions | `AIKit` | `modules/ai.md` — development only; never ship a secret key in an app |

Keep the module package as a local package until a real Git package URL exists. Supabase Swift is pulled only when using `AuthKit` or `DatabaseKit`; the UI-only products do not need Supabase.

## Agent workflow

1. Match the request to one module and read only its guide.
2. Check the host project's deployment target, package setup, and existing services before editing.
3. Add only that Swift package product. If the project cannot add local packages, copy only the required Swift files and explain the dependency/configuration work still needed.
4. Reuse app-owned Supabase configuration and authenticated client. Never add service-role or OpenAI secrets to app files.
5. Build the requested iOS target and report missing Apple/Supabase/App Store setup separately from source errors.

The package's `MashiCoreKit` umbrella product re-exports every module for compatibility. Prefer the individual products to avoid pulling in Supabase when the app only needs UI or local storage.

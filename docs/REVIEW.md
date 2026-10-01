# MashiCoreKit review notes

This release is an isolated, cleaned package assembled from the source working tree. The original repository already had local edits and untracked module files; those were preserved.

## Changes in this package

- Split the monolithic target into one SwiftPM target/product per feature. UI and local-storage products no longer depend on Supabase. Kept `MashiCoreKit` as an umbrella product for compatibility.
- Replaced the generic/inaccurate README with exact requirements, install steps, dependencies, examples, and production cautions.
- Added short AI entry/module guides so an agent can load just the needed integration notes.
- Generated a cryptographic nonce for Apple sign-in rather than reusing a literal nonce.
- Prevented streak freezes from extending streaks when the prior day was inactive.
- Made the splash background truly optional.
- Removed Finder metadata, preview-only resources, and the empty placeholder test source from this release.

## Remaining limitations

- `AIKit` sends provider requests directly from the app; it is development-only until moved behind a backend proxy.
- Generic database CRUD uses raw table names and does not enforce row ownership. The host app must configure RLS and use the authenticated Supabase client.
- Subscription state is cached in UserDefaults for UI convenience. Re-validate verified StoreKit entitlements wherever access matters.
- The package does not have a remote Git URL/tag, so Xcode must add it as a local package for now.
- Tests in the original repository are placeholders. This package still needs module-specific unit/UI tests and integration builds in a host iOS app.

## Compatibility

The project declares iOS 16+, macOS 13+ for package tooling, and Swift tools 6.2. Supabase Swift is pinned by a compatible 2.x range. Run the package and a representative host app build before treating this as a production release.

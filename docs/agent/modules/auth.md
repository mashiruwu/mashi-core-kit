# Supabase Auth

Product/import: `AuthKit`. Requires Supabase Swift 2.x and iOS 16+.

Create `MashiAuthConfiguration(supabaseURL:supabaseKey:)` with the app's Supabase project URL and publishable/anon key, then `MashiAuthService(configuration:)`. Inject `MashiAuthServiceProtocol` into app views. Use `authStateChanges` to update the root navigation after sign-in/out.

Apple sign-in now generates a per-request nonce and sends the SHA-256 nonce to AuthenticationServices while giving the raw nonce to Supabase. The host app must still enable Sign in with Apple and configure Apple's provider in Supabase. Never put a service-role key in the app. Current UI copy is English and is not theme-injected.

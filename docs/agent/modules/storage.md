# Storage

Product/import: `StorageKit`. No external dependencies. iOS 16+.

Use `@MashiStorage("settings", store: .standard) var settings = Settings()` for a `Codable` value that should update SwiftUI views. Pass an app group `UserDefaults(suiteName:)` as `store` when sharing preferences. Keep keys stable and app-specific; this is local preferences storage, not secure storage.

Do not store passwords, auth tokens, payment state, or large files here. Encoding failures fall back to the previous value and are logged.

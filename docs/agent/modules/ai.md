# AIKit — development use only

Product/import: `AIKit`. No external package dependency. iOS 16+.

`MashiOpenAIClient(apiKey:)` sends a Chat Completions request directly to OpenAI. `generateText(messages:model:)` returns text; `generateStructuredData(messages:model:responseType:)` decodes JSON mode into `Decodable`.

**Do not ship this direct client in a user app.** A mobile binary or Info.plist is inspectable, so an OpenAI API key would be extractable. Production apps must call an authenticated backend proxy that holds the provider key. This client has no streaming, tool-calling, retry policy, or server-side quota enforcement. Its default model is `gpt-4o-mini`; choose a model supported by the endpoint and account. Never add a real key to source, project settings, previews, or bundled resources.

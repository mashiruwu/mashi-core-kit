# Supabase Database

Product/import: `DatabaseKit`. Requires Supabase Swift 2.x, `AuthKit`, and iOS 16+.

Prefer `MashiDatabaseClient(client: authenticatedSupabaseClient)` so database calls share the user's auth session. `MashiSupabaseRepository` provides generic fetch/insert/update/delete operations; decode rows into app-owned `Codable`/`Decodable` models.

The table name is a raw string and this wrapper does not add user filters. Create correct Row Level Security policies and use only the app publishable/anon key. Add explicit ownership predicates where they fit the schema. Never use a service-role key in a client app.

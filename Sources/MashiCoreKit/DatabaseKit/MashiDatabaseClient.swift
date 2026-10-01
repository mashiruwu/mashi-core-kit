import Foundation
import AuthKit
import Supabase

public class MashiDatabaseClient {
	public let client: SupabaseClient

	public init(configuration: MashiAuthConfiguration) {
		self.client = SupabaseClient(
			supabaseURL: configuration.supabaseURL,
			supabaseKey: configuration.supabaseKey
		)
	}

	public init(client: SupabaseClient) {
		self.client = client
	}
}

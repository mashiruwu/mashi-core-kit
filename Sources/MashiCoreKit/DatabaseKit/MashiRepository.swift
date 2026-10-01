import Foundation
import Supabase

public protocol MashiRepository {
	func fetchAll<T: Decodable>(table: String) async throws -> [T]
	func fetchById<T: Decodable>(table: String, id: String) async throws -> T
	func insert<T: Encodable>(table: String, item: T) async throws
	func update<T: Encodable>(table: String, id: String, item: T) async throws
	func delete(table: String, id: String) async throws
}

public class MashiSupabaseRepository: MashiRepository {
	private let db: MashiDatabaseClient
	
	public init(db: MashiDatabaseClient) {
		self.db = db
	}
	
	public func fetchAll<T: Decodable>(table: String) async throws -> [T] {
		try await db.client.from(table).select().execute().value
	}
	
	public func fetchById<T: Decodable>(table: String, id: String) async throws -> T {
		try await db.client.from(table).select().eq("id", value: id).single().execute().value
	}
	
	public func insert<T: Encodable>(table: String, item: T) async throws {
		try await db.client.from(table).insert(item).execute()
	}
	
	public func update<T: Encodable>(table: String, id: String, item: T) async throws {
		try await db.client.from(table).update(item).eq("id", value: id).execute()
	}
	
	public func delete(table: String, id: String) async throws {
		try await db.client.from(table).delete().eq("id", value: id).execute()
	}
}

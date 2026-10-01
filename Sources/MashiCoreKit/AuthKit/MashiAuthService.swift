import Foundation
import Supabase

public enum MashiAuthState: Sendable {
	case signedIn(userID: String)
	case signedOut
}

public protocol MashiAuthServiceProtocol: Sendable {
	func signIn(email: String, password: String) async throws
	func signUp(email: String, password: String) async throws
	func signInWithApple(idToken: String, nonce: String) async throws
	func signOut() async throws
	func currentUserID() async throws -> String?
	var authStateChanges: AsyncStream<MashiAuthState> { get }
}

public final class MashiAuthService: MashiAuthServiceProtocol, @unchecked Sendable {
	private let client: SupabaseClient
	
	public init(configuration: MashiAuthConfiguration) {
		self.client = SupabaseClient(
			supabaseURL: configuration.supabaseURL,
			supabaseKey: configuration.supabaseKey
		)
	}
	
	public init(client: SupabaseClient) {
		self.client = client
	}
	
	public func signIn(email: String, password: String) async throws {
		do {
			try await client.auth.signIn(email: email, password: password)
		} catch {
			throw mapError(error)
		}
	}
	
	public func signUp(email: String, password: String) async throws {
		do {
			try await client.auth.signUp(email: email, password: password)
		} catch {
			throw mapError(error)
		}
	}
	
	public func signInWithApple(idToken: String, nonce: String) async throws {
		do {
			try await client.auth.signInWithIdToken(
				credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
			)
		} catch {
			throw mapError(error)
		}
	}
	
	public func signOut() async throws {
		try await client.auth.signOut()
	}
	
	public func currentUserID() async throws -> String? {
		let session = try await client.auth.session
		return session.user.id.uuidString
	}
	
	public var authStateChanges: AsyncStream<MashiAuthState> {
		AsyncStream { continuation in
			let task = Task {
				for await state in client.auth.authStateChanges {
					if let session = state.session {
						continuation.yield(.signedIn(userID: session.user.id.uuidString))
					} else {
						continuation.yield(.signedOut)
					}
				}
			}
			continuation.onTermination = { _ in task.cancel() }
		}
	}
	
	private func mapError(_ error: Error) -> MashiAuthError {
		return .unknown(error.localizedDescription)
	}
}

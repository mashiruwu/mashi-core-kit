import Foundation

public enum MashiAuthError: LocalizedError {
	case notAuthenticated
	case invalidCredentials
	case unknown(String)
	
	public var errorDescription: String? {
		switch self {
		case .notAuthenticated: return "User is not authenticated."
		case .invalidCredentials: return "Invalid email or password."
		case .unknown(let msg): return msg
		}
	}
}

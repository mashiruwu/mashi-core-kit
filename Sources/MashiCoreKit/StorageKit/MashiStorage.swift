import SwiftUI
import Combine

/// A property wrapper type that reflects a Codable value from `UserDefaults` and
/// invalidates a view on a change in value in that user default.
///
/// This acts exactly like SwiftUI's `@AppStorage`, but supports any `Codable` type
/// by transparently JSON encoding/decoding the data under the hood.
@propertyWrapper
public struct MashiStorage<T: Codable>: DynamicProperty {
	@AppStorage private var rawValue: Data
	private let defaultValue: T
	
	/// Creates a property that can read and write to a Codable user default.
	/// - Parameters:
	///   - wrappedValue: The default value if a value is not specified for the given key.
	///   - key: The key to read and write the value to in the user defaults store.
	///   - store: The user defaults store to read and write to. A value of `nil` will use the standard user defaults.
	public init(wrappedValue: T, _ key: String, store: UserDefaults? = nil) {
		self.defaultValue = wrappedValue
		
		// We initialize the AppStorage with an empty Data fallback.
		// It will only be used if the key doesn't exist yet.
		let initialData = (try? JSONEncoder().encode(wrappedValue)) ?? Data()
		self._rawValue = AppStorage(wrappedValue: initialData, key, store: store)
	}
	
	public var wrappedValue: T {
		get {
			do {
				return try JSONDecoder().decode(T.self, from: rawValue)
			} catch {
				// Fallback to default if decoding fails (or if the Data was the empty default)
				return defaultValue
			}
		}
		nonmutating set {
			do {
				let encoded = try JSONEncoder().encode(newValue)
				rawValue = encoded
			} catch {
				print("❌ [MashiStorage] Failed to encode value for UserDefaults: \(error)")
			}
		}
	}
	
	public var projectedValue: Binding<T> {
		Binding(
			get: { wrappedValue },
			set: { wrappedValue = $0 }
		)
	}
}

import SwiftUI

#if DEBUG
// A complex custom Codable type
private struct UserProfile: Codable, Equatable {
	var id: UUID
	var username: String
	var age: Int
	var favoriteTags: [String]
}

struct MashiStoragePreview_Previews: PreviewProvider {
	static var previews: some View {
		StorageDemo()
	}
}

private struct StorageDemo: View {
	// Instead of being limited to String/Int like @AppStorage,
	// @MashiStorage flawlessly handles the entire UserProfile struct!
	@MashiStorage("preview_user_profile")
	private var profile = UserProfile(
		id: UUID(),
		username: "New User",
		age: 20,
		favoriteTags: ["swift", "coding"]
	)
	
	@State private var newTag: String = ""

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text(String(localized: "Profile Settings"))) {
					TextField("Username", text: $profile.username)
					Stepper("Age: \(profile.age)", value: $profile.age, in: 10...100)
				}
				
				Section(header: Text(String(localized: "Favorite Tags (Array)"))) {
					ForEach(profile.favoriteTags, id: \.self) { tag in
						Text(tag)
					}
					.onDelete { indexSet in
						profile.favoriteTags.remove(atOffsets: indexSet)
					}
					
					HStack {
						TextField("New Tag", text: $newTag)
						Button(String(localized: "Add")) {
							if !newTag.isEmpty {
								profile.favoriteTags.append(newTag)
								newTag = ""
							}
						}
					}
				}
				
				Section {
					Button(String(localized: "Reset Profile to Defaults")) {
						profile = UserProfile(
							id: UUID(),
							username: "New User",
							age: 20,
							favoriteTags: ["swift", "coding"]
						)
					}
					.foregroundStyle(.red)
				}
				
				Section(footer: Text(String(localized: "All changes are automatically JSON-encoded, saved to UserDefaults, and trigger SwiftUI re-renders in real-time using @MashiStorage."))) {
					EmptyView()
				}
			}
			.navigationTitle(String(localized: "StorageKit"))
		}
	}
}
#endif

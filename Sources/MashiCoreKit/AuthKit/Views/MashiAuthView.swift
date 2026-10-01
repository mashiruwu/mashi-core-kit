import SwiftUI
import AuthenticationServices
import CryptoKit

public struct MashiAuthView: View {
	let authService: MashiAuthServiceProtocol
	let onAuthSuccess: () -> Void
	
	@State private var email = ""
	@State private var password = ""
	@State private var isLoading = false
	@State private var errorMessage: String?
	@State private var isSignUp = false
	@State private var appleNonce: String?
	
	public init(authService: MashiAuthServiceProtocol, onAuthSuccess: @escaping () -> Void) {
		self.authService = authService
		self.onAuthSuccess = onAuthSuccess
	}
	
	public var body: some View {
		VStack(spacing: 20) {
			Text(isSignUp ? "Create Account" : "Welcome Back")
				.font(.largeTitle.bold())
				.padding(.bottom, 20)
			
			VStack(spacing: 12) {
				TextField("Email", text: $email)
					.textFieldStyle(.roundedBorder)
#if os(iOS)
					.keyboardType(.emailAddress)
					.textInputAutocapitalization(.never)
#endif
				
				SecureField("Password", text: $password)
					.textFieldStyle(.roundedBorder)
			}
			
			if let errorMessage {
				Text(errorMessage)
					.foregroundStyle(.red)
					.font(.footnote)
			}
			
			Button {
				Task { await handleEmailAuth() }
			} label: {
				HStack {
					if isLoading {
						ProgressView().tint(.white)
					}
					Text(isSignUp ? "Sign Up" : "Sign In")
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(Color.blue)
				.foregroundStyle(.white)
				.cornerRadius(10)
			}
			.disabled(isLoading || email.isEmpty || password.isEmpty)
			
			Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
				isSignUp.toggle()
				errorMessage = nil
			}
			.font(.footnote)
			
			Divider().padding(.vertical)
			
			SignInWithAppleButton(
				onRequest: { request in
					request.requestedScopes = [.fullName, .email]
					let nonce = Self.makeNonce()
					appleNonce = nonce
					request.nonce = Self.sha256(nonce)
				},
				onCompletion: { result in
					Task { await handleAppleAuth(result: result) }
				}
			)
			.signInWithAppleButtonStyle(.black)
			.frame(height: 50)
		}
		.padding()
	}
	
	private func handleEmailAuth() async {
		isLoading = true
		errorMessage = nil
		do {
			if isSignUp {
				try await authService.signUp(email: email, password: password)
			} else {
				try await authService.signIn(email: email, password: password)
			}
			onAuthSuccess()
		} catch {
			errorMessage = error.localizedDescription
		}
		isLoading = false
	}
	
	private func handleAppleAuth(result: Result<ASAuthorization, Error>) async {
		switch result {
		case .success(let auth):
			if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential,
			let identityTokenData = appleIDCredential.identityToken,
			let identityToken = String(data: identityTokenData, encoding: .utf8) {
				guard let nonce = appleNonce else {
					errorMessage = "Could not verify the Apple sign-in request. Try again."
					return
				}
				do {
					try await authService.signInWithApple(idToken: identityToken, nonce: nonce)
					appleNonce = nil
					onAuthSuccess()
				} catch {
					errorMessage = error.localizedDescription
				}
			}
		case .failure(let error):
			errorMessage = error.localizedDescription
		}
	}

	private static func makeNonce() -> String {
		UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
	}

	private static func sha256(_ value: String) -> String {
		SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
	}
}

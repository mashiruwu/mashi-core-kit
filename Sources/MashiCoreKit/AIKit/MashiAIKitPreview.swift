import SwiftUI

#if DEBUG
struct AIKitPreview_Previews: PreviewProvider {
	static var previews: some View {
		AIKitDemo()
	}
}

private struct AIKitDemo: View {
	@State private var input: String = ""
	@State private var responseText: String = "Type something to generate..."
	@State private var isGenerating: Bool = false
	
	// We mock a client for the preview if no API key is available
	private let client: MashiOpenAIClient = {
		do {
			return try MashiOpenAIClient.live()
		} catch {
			// Provide a dummy key for preview rendering purposes only.
			// In a real app, you would handle this error.
			return MashiOpenAIClient(apiKey: "preview-dummy-key")
		}
	}()

	var body: some View {
		VStack(spacing: 20) {
			Text(String(localized: "🤖 AIKit"))
				.font(.largeTitle)
				.bold()
			
			ScrollView {
				Text(responseText)
					.padding()
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(Color.gray.opacity(0.16))
					.cornerRadius(12)
			}
			
			if isGenerating {
				ProgressView("Thinking...")
			}
			
			HStack {
				TextField("Ask something...", text: $input)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				
				Button(String(localized: "Send")) {
					Task {
						await generateResponse()
					}
				}
				.disabled(input.isEmpty || isGenerating)
				.buttonStyle(.borderedProminent)
			}
		}
		.padding()
	}
	
	private func generateResponse() async {
		isGenerating = true
		defer { isGenerating = false }
		
		do {
			let messages = [
				MashiAIChatMessage.system("You are a helpful assistant. Keep your answers short."),
				MashiAIChatMessage.user(input)
			]
			
			responseText = try await client.generateText(messages: messages)
			input = ""
		} catch {
			responseText = "Error: \(error.localizedDescription)\n\n(Did you set OPENAI_API_KEY?)"
		}
	}
}
#endif

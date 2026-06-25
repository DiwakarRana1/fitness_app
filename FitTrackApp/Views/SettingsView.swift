import SwiftUI

struct SettingsView: View {
    @State private var geminiKey: String = ""
    @State private var openAIKey: String = ""
    @AppStorage("preferredAIModel") private var preferredAIModel: String = "Gemini"
    @State private var showSavedAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API Credentials")) {
                    SecureField("Gemini API Key", text: $geminiKey)
                    SecureField("OpenAI API Key", text: $openAIKey)
                }
                
                Section(header: Text("AI Model Preference")) {
                    Picker("Active AI Model", selection: $preferredAIModel) {
                        Text("Gemini 1.5 Flash").tag("Gemini")
                        Text("ChatGPT GPT-4o").tag("ChatGPT")
                    }
                    .pickerStyle(.segmented)
                }
                
                Button(action: saveSettings) {
                    Text("Save Settings")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Settings")
            .onAppear(perform: loadCredentials)
            .alert("Settings Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func loadCredentials() {
        geminiKey = KeychainHelper.shared.read(forKey: "gemini_api_key") ?? ""
        openAIKey = KeychainHelper.shared.read(forKey: "openai_api_key") ?? ""
    }
    
    private func saveSettings() {
        KeychainHelper.shared.save(geminiKey, forKey: "gemini_api_key")
        KeychainHelper.shared.save(openAIKey, forKey: "openai_api_key")
        showSavedAlert = true
    }
}

#Preview {
    SettingsView()
}

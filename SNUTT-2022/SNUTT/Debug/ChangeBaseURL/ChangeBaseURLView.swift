//
//  ChangeBaseURLView.swift
//  SNUTT
//
//  Created by 박신홍 on 1/4/25.
//

#if DEBUG
import SwiftUI

struct ChangeBaseURLView: View {
    @State private var baseURL: String = ""
    @State private var showSaveConfirmation = false

    private var currentBaseURL: String {
        NetworkConfiguration.serverBaseURL
    }

    var body: some View {
        Form {
            Section(header: Text("Current Base URL")) {
                Text(currentBaseURL)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Change Base URL")) {
                TextField("Enter new base URL", text: $baseURL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
            }

            Section {
                Button("Save") {
                    saveBaseURL(baseURL)
                    showSaveConfirmation = true
                }
                .disabled(baseURL.isEmpty || baseURL == currentBaseURL)
            }
        }
        .onAppear {
            baseURL = currentBaseURL
        }
        .alert("Base URL Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {
                exit(0)
            }
        }
        .navigationTitle("Change Base URL")
    }

    private func saveBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: customBaseURLKey)
    }

    private func loadBaseURL() -> String? {
        UserDefaults.standard.string(forKey: customBaseURLKey)
    }

    let customBaseURLKey = "customBaseURL"
}

@available(iOS 17, *)
#Preview {
    NavigationStack {
        ChangeBaseURLView()
    }
}
#endif

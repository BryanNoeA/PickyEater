import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Premium Status", systemImage: "star.fill")
                            .foregroundStyle(appState.isPremium ? .yellow : .primary)
                        Spacer()
                        Text(appState.isPremium ? "Unlocked" : "Free")
                            .font(.subheadline)
                            .foregroundStyle(appState.isPremium ? .yellow : .secondary)
                    }

                    if !appState.isPremium {
                        Button("Unlock Premium") {
                            dismiss()
                            appState.showPaywall = true
                        }
                        .foregroundStyle(Color.accentColor)

                        Button {
                            Task {
                                isRestoring = true
                                await storeKit.restorePurchases(appState: appState)
                                isRestoring = false
                            }
                        } label: {
                            HStack {
                                Text("Restore Purchase")
                                if isRestoring {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isRestoring)
                    }
                } header: {
                    Text("Subscription")
                }

                Section {
                    Link(destination: URL(string: "https://github.com")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("Legal")
                } footer: {
                    Text("A privacy policy link is required for apps using location and in-app purchases. Replace this URL before submitting to the App Store.")
                        .font(.caption)
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

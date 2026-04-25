import SwiftUI

struct SettingsView: View {
    @Binding var showPaywall: Bool
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            List {
                premiumSection
                legalSection
                aboutSection
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

    private var premiumSection: some View {
        Section("Subscription") {
            HStack {
                Label("Premium Status", systemImage: "star.fill")
                    .foregroundStyle(storeKit.isPurchased ? .yellow : .primary)
                Spacer()
                Text(storeKit.isPurchased ? "Unlocked ✓" : "Free")
                    .font(.subheadline)
                    .foregroundStyle(storeKit.isPurchased ? .yellow : .secondary)
            }

            if !storeKit.isPurchased {
                Button("Unlock Premium") {
                    dismiss()
                    showPaywall = true
                }
                .foregroundStyle(Color.accentColor)

                Button {
                    Task {
                        isRestoring = true
                        await storeKit.restorePurchases()
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
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://example.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
        } header: {
            Text("Legal")
        } footer: {
            Text("Replace the privacy policy URL before submitting to the App Store.")
                .font(.caption)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView(showPaywall: .constant(false))
        .environment(StoreKitManager())
}

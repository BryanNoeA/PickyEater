import SwiftUI

struct SettingsView: View {
    @Binding var showPaywall: Bool
    @Environment(StoreKitManager.self)  private var storeKit
    @Environment(\.dismiss) private var dismiss

    @State private var isRestoring  = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ── Top row: drag handle + Done ───────────────────────
                    SheetTopBar {
                        Button("Done") { dismiss() }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                    }

                    // ── Title ─────────────────────────────────────────────
                    Text("Settings")
                        .font(.system(.title, design: .serif).weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    // ── Premium card ──────────────────────────────────────
                    settingsCard(header: "Premium") {
                        HStack {
                            Label("Status", systemImage: "star.fill")
                                .foregroundStyle(storeKit.isPurchased
                                    ? Color(red: 1, green: 0.8, blue: 0.2) : .primary)
                            Spacer()
                            if storeKit.isPurchased {
                                Label("Unlocked", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(red: 1, green: 0.8, blue: 0.2))
                            } else {
                                Text("Free")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if !storeKit.isPurchased {
                            Divider()

                            Button(action: openUpgradeFlow) {
                                HStack {
                                    Text("Unlock Premium")
                                        .foregroundStyle(Color.accentColor)
                                    Spacer()
                                }
                            }

                            Divider()

                            Button(action: restorePurchase) {
                                HStack {
                                    Text("Restore Purchase")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if isRestoring { ProgressView() }
                                }
                            }
                            .disabled(isRestoring)
                        }
                    }

                    // ── Legal card ────────────────────────────────────────
                    settingsCard(header: "Legal") {
                        Link(destination: URL(string: "https://bryannoea.github.io/PickyEater/privacy.html")!) {
                            HStack {
                                Label("Privacy Policy", systemImage: "hand.raised.fill")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    // ── About card ────────────────────────────────────────
                    settingsCard(header: "About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(Color.peBackground)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .presentationBackground(Color.peBackground)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }

    // MARK: - Card builder

    @ViewBuilder
    private func settingsCard<Content: View>(
        header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func openUpgradeFlow() {
        dismiss()
        showPaywall = true
    }

    private func restorePurchase() {
        Task {
            isRestoring = true
            await storeKit.restorePurchases()
            isRestoring = false
        }
    }
}

#Preview {
    Color.peBackground.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SettingsView(showPaywall: .constant(false))
                .environment(StoreKitManager())
        }
}

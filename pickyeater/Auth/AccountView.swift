import SwiftUI
import Auth

/// Account management screen — shown from Settings when the user is signed in.
///
/// Lets the user:
///   • See their account email and premium status
///   • Sign out (locks premium on this device immediately)
///   • Delete their account (removes Supabase profile data, satisfies App Review Guideline 5.1.1)
struct AccountView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.dismiss) private var dismiss

    @State private var showSignOutConfirmation  = false
    @State private var showDeleteConfirmation   = false
    @State private var isDeleting               = false

    var body: some View {
        List {
            // ── Account info ──────────────────────────────────────────────
            Section("Account") {
                HStack {
                    Label("Email", systemImage: "envelope")
                    Spacer()
                    Text(authManager.currentUserEmail ?? "—")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Show which provider they used (Apple / Google / email)
                HStack {
                    Label("Signed in with", systemImage: "person.badge.key")
                    Spacer()
                    Text(providerLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // ── Premium status ────────────────────────────────────────────
            Section("Premium") {
                HStack {
                    Label("Status", systemImage: "star.fill")
                        .foregroundStyle(profileManager.isPremium ? .yellow : .primary)
                    Spacer()
                    Text(profileManager.isPremium ? "Unlocked ✓" : "Free")
                        .font(.subheadline)
                        .foregroundStyle(profileManager.isPremium ? .yellow : .secondary)
                }
                if profileManager.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }

            // ── Sign out ──────────────────────────────────────────────────
            Section {
                Button("Sign Out", action: confirmSignOut)
                    .foregroundStyle(.red)
            } footer: {
                Text("Signing out locks premium features on this device until you sign back in.")
                    .font(.caption)
            }

            // ── Danger zone ───────────────────────────────────────────────
            Section {
                Button(role: .destructive, action: confirmDelete) {
                    HStack {
                        Text(isDeleting ? "Deleting…" : "Delete Account")
                        if isDeleting { Spacer(); ProgressView() }
                    }
                }
                .disabled(isDeleting)
            } header: {
                Text("Danger Zone")
            } footer: {
                // Required disclosure text for App Review Guideline 5.1.1
                Text("Deleting your account permanently removes your profile and premium status from our servers. This action cannot be undone.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My Account")
        .navigationBarTitleDisplayMode(.inline)
        // ── Sign out confirmation ─────────────────────────────────────────
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive, action: signOut)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Premium features will be locked on this device until you sign back in.")
        }
        // ── Delete confirmation ───────────────────────────────────────────
        .confirmationDialog("Delete Account", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete My Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account and premium status. It cannot be undone.")
        }
    }

    // MARK: - Helpers

    /// Best-guess label for the provider based on the email domain and session metadata.
    private var providerLabel: String {
        // Supabase stores identities — use the first provider's name
        if let identities = authManager.session?.user.identities,
           let first = identities.first {
            switch first.provider {
            case "apple":  return "Apple"
            case "google": return "Google"
            default:       return "Email"
            }
        }
        return "Email"
    }

    // MARK: - Actions

    private func confirmSignOut()  { showSignOutConfirmation = true }
    private func confirmDelete()   { showDeleteConfirmation  = true }

    private func signOut() {
        Task {
            // Clear cache FIRST so premium features lock before the sheet dismisses
            profileManager.clearCache()
            await authManager.signOut()
            dismiss()
        }
    }

    private func deleteAccount() {
        Task {
            isDeleting = true
            if let userID = authManager.currentUserID {
                // Deletes the profiles row (user's personal data)
                // The auth.users row is removed server-side via the CASCADE rule
                // or a Supabase Edge Function (see SupabaseConfig.swift notes)
                try? await profileManager.deleteProfileData(for: userID)
            }
            await authManager.signOut()
            isDeleting = false
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environment(AuthManager())
            .environment(ProfileManager())
    }
}

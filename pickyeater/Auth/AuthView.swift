import SwiftUI
import AuthenticationServices

/// Sign-in / create-account sheet.
///
/// Presents three auth options:
///   1. Sign in with Apple (primary — required by App Review when social login exists)
///   2. Sign in with Google
///   3. Email + password (with toggle between sign-in and sign-up modes)
///
/// Dismisses automatically when `authManager.isSignedIn` becomes true.
struct AuthView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // ── Hero ──────────────────────────────────────────────
                    heroHeader

                    // ── Social sign-in ────────────────────────────────────
                    VStack(spacing: 12) {
                        appleButton
                        googleButton
                    }

                    // ── Divider ───────────────────────────────────────────
                    orDivider

                    // ── Email / password form ─────────────────────────────
                    emailForm

                    // ── Error message ─────────────────────────────────────
                    if !authManager.errorMessage.isEmpty {
                        Text(authManager.errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    // ── Mode toggle (sign-in ↔ create account) ────────────
                    modeToggle
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", action: cancel)
                }
            }
            // Dismiss as soon as sign-in succeeds
            .onChange(of: authManager.isSignedIn) { _, signedIn in
                if signedIn { dismiss() }
            }
        }
    }

    // MARK: - Subviews

    private var heroHeader: some View {
        VStack(spacing: 8) {
            Text("🎲")
                .font(.system(size: 52))
                .accessibilityHidden(true)
            Text(viewModel.mode == .signIn
                 ? "Welcome back"
                 : "Join Picky Eater")
                .font(.system(size: 24, weight: .bold))
            Text(viewModel.mode == .signIn
                 ? "Sign in to access your premium account"
                 : "Create a free account to unlock Premium")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    /// Native Apple sign-in button — required to use this exact button style
    /// when Sign in with Apple is offered (App Store Review Guideline 4.8).
    private var appleButton: some View {
        SignInWithAppleButton(
            viewModel.mode == .signIn ? .signIn : .signUp
        ) { request in
            // onRequest is called synchronously before Apple's sheet appears.
            // We generate a nonce here and embed its SHA-256 hash in the request
            // so Apple can sign it into the JWT for Supabase to verify later.
            let hashedNonce = viewModel.prepareNonce()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce
        } onCompletion: { result in
            Task {
                // Pass the RAW nonce — AuthManager hashes it and sends to Supabase
                await authManager.handleAppleSignIn(result, nonce: viewModel.currentNonce)
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityLabel("Sign in with Apple")
    }

    /// Google sign-in button — styled to match Apple's button height.
    /// Add a "google_logo" image asset to Assets.xcassets for the real Google "G".
    private var googleButton: some View {
        Button(action: signInWithGoogle) {
            HStack(spacing: 10) {
                // Replace with Image("google_logo") once you add the asset
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                Text("Continue with Google")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            }
        }
        .disabled(authManager.isLoading)
        .accessibilityLabel("Sign in with Google")
    }

    private var orDivider: some View {
        HStack {
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            Text("or").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 8)
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
        }
    }

    private var emailForm: some View {
        VStack(spacing: 12) {
            // Email field
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Password field
            SecureField("Password (6+ characters)", text: $viewModel.password)
                .textContentType(viewModel.mode == .signUp ? .newPassword : .password)
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Submit button
            Button(action: submitEmail) {
                Group {
                    if authManager.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(viewModel.submitLabel)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.canSubmit ? Color.accentColor : Color.gray,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .disabled(!viewModel.canSubmit || authManager.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.canSubmit)
        }
    }

    private var modeToggle: some View {
        HStack(spacing: 4) {
            Text(viewModel.togglePrompt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(viewModel.toggleActionLabel, action: toggleMode)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Actions

    private func cancel() { dismiss() }

    private func signInWithGoogle() {
        Task { await authManager.signInWithGoogle() }
    }

    private func submitEmail() {
        Task {
            if viewModel.mode == .signIn {
                await authManager.signIn(email: viewModel.email, password: viewModel.password)
            } else {
                await authManager.signUp(email: viewModel.email, password: viewModel.password)
            }
        }
    }

    private func toggleMode() { viewModel.toggleMode() }
}

#Preview {
    AuthView()
        .environment(AuthManager())
}

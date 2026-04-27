import SwiftUI
import Supabase
import AuthenticationServices
import CryptoKit
import UIKit
import GoogleSignIn

/// Manages the Supabase auth session for the entire app.
///
/// Inject into the SwiftUI environment via `.environment(authManager)` and
/// read with `@Environment(AuthManager.self)` in any view.
@Observable
@MainActor
final class AuthManager {

    // MARK: - Published state

    /// The current Supabase session. Nil when not signed in.
    var session: Session? = nil

    /// True while a sign-in or sign-out request is in flight.
    var isLoading: Bool = false

    /// Human-readable error to surface in the UI. Empty string = no error.
    var errorMessage: String = ""

    // MARK: - Convenience

    var isSignedIn: Bool { session != nil }
    var currentUserID: UUID? { session?.user.id }
    var currentUserEmail: String? { session?.user.email }

    // MARK: - Init

    init() {
        // Try to restore a persisted session from a previous launch.
        // Supabase stores the session in the Keychain automatically.
        Task { await restoreSession() }
    }

    private func restoreSession() async {
        session = try? await SupabaseConfig.client.auth.session
    }

    // MARK: - Sign in with Apple

    /// Called from AuthView's SignInWithAppleButton `onCompletion` callback.
    ///
    /// The `nonce` parameter must be the *raw* (unhashed) nonce that was
    /// generated in `onRequest`. Apple embeds the SHA-256 of it in the JWT;
    /// Supabase hashes our raw nonce and compares them to verify the token.
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, nonce: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let authorization = try result.get()

            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData  = credential.identityToken,
                  let idToken    = String(data: tokenData, encoding: .utf8) else {
                throw AuthError.invalidCredential
            }

            // Sign in via Supabase — it verifies Apple's JWT server-side
            // signInWithIdToken returns Session directly (no .session wrapper)
            session = try await SupabaseConfig.client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            // Persist Apple's stable user identifier so ProfileManager can
            // detect and prevent duplicate accounts on future sign-in attempts.
            // _ = suppresses the "unused result" warning on the discarded response.
            if let userID = currentUserID {
                let payload = AppleIdentifierUpdate(id: userID, appleUserIdentifier: credential.user)
                _ = try? await SupabaseConfig.client
                    .from("profiles")
                    .upsert(payload, onConflict: "id")
                    .execute()
            }

        } catch {
            errorMessage = formatted(error)
        }

        isLoading = false
    }

    // MARK: - Sign in with Google

    /// Presents the Google sign-in browser sheet and exchanges the token with Supabase.
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = ""

        do {
            // Find the frontmost active scene, then walk up the presented
            // view controller chain to find the topmost one.
            // This matters because AuthView is itself a sheet — if we pass
            // the root VC, UIKit sees it already has a presented VC and
            // refuses to present Google's login on top of it.
            guard let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootVC = scene.keyWindow?.rootViewController else {
                throw AuthError.noWindowScene
            }

            // Walk to the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            let result     = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            let idToken    = result.user.idToken?.tokenString ?? ""
            let accessToken = result.user.accessToken.tokenString

            guard !idToken.isEmpty else { throw AuthError.invalidCredential }

            // Exchange Google's tokens with Supabase
            session = try await SupabaseConfig.client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )

        } catch {
            errorMessage = formatted(error)
        }

        isLoading = false
    }

    // MARK: - Email sign-in / sign-up

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            session = try await SupabaseConfig.client.auth
                .signIn(email: email, password: password)
        } catch {
            errorMessage = formatted(error)
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            // signUp returns AuthResponse; .session is Session? (nil if email confirmation required)
            session = try await SupabaseConfig.client.auth
                .signUp(email: email, password: password)
                .session
        } catch {
            errorMessage = formatted(error)
        }
        isLoading = false
    }

    // MARK: - Sign out

    func signOut() async {
        do {
            try await SupabaseConfig.client.auth.signOut()
        } catch {
            // Best-effort: clear local state even if the server call fails
        }
        session = nil
    }

    // MARK: - Error formatting

    private func formatted(_ error: Error) -> String {
        let desc = error.localizedDescription.lowercased()
        if desc.contains("invalid login credentials") || desc.contains("invalid email or password") {
            return "Incorrect email or password."
        }
        if desc.contains("already registered") || desc.contains("already exists") {
            return "An account with this email already exists. Try signing in instead."
        }
        if desc.contains("cancelled") || desc.contains("cancel") {
            return ""   // user cancelled — not an error worth showing
        }
        if desc.contains("network") || desc.contains("offline") {
            return "No internet connection. Please try again."
        }
        return "Something went wrong. Please try again."
    }
}

// MARK: - Nonce helpers for Sign in with Apple

extension AuthManager {

    /// Generates a random alphanumeric string used as a one-time nonce.
    /// The nonce prevents replay attacks: Apple embeds SHA-256(nonce) in the
    /// JWT so Supabase can verify that the token was issued for this request.
    static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes   = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    /// Returns the SHA-256 hex digest of the input string.
    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}

// MARK: - Error types

enum AuthError: LocalizedError {
    case invalidCredential
    case noWindowScene

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Could not read the sign-in credential."
        case .noWindowScene:     return "Could not find a window to present sign-in."
        }
    }
}

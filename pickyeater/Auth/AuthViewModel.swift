import Foundation

/// Local UI state for AuthView — form fields, mode toggle, and nonce management.
/// Kept separate from AuthManager so the manager stays free of view-layer concerns.
@Observable
final class AuthViewModel {

    // MARK: - Mode

    /// Whether the form is in "sign in" or "create account" mode.
    enum Mode { case signIn, signUp }

    var mode: Mode = .signIn

    // MARK: - Form fields

    var email: String    = ""
    var password: String = ""

    // MARK: - Nonce (Sign in with Apple)

    /// The raw nonce for the current Apple sign-in request.
    /// Generated in `onRequest`, consumed in `onCompletion`.
    private(set) var currentNonce: String = ""

    /// Call this inside `SignInWithAppleButton`'s `onRequest` closure.
    /// Generates a fresh nonce, stores the raw version, and returns the
    /// SHA-256 hash that Apple expects in the request.
    func prepareNonce() -> String {
        currentNonce = AuthManager.randomNonce()
        return AuthManager.sha256(currentNonce)
    }

    // MARK: - Validation

    var isEmailValid: Bool    { email.contains("@") && email.contains(".") }
    var isPasswordValid: Bool { password.count >= 6 }
    var canSubmit: Bool       { isEmailValid && isPasswordValid }

    // MARK: - Mode toggle

    func toggleMode() {
        mode     = (mode == .signIn) ? .signUp : .signIn
        password = ""   // clear password when switching modes for security
    }

    var submitLabel: String       { mode == .signIn ? "Sign In"       : "Create Account" }
    var togglePrompt: String      { mode == .signIn ? "No account?"   : "Already have an account?" }
    var toggleActionLabel: String { mode == .signIn ? "Create one →"  : "Sign In →" }
    var navigationTitle: String   { mode == .signIn ? "Sign In"       : "Create Account" }
}

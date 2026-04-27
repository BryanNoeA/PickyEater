import SwiftUI

/// Shown on the paywall when the user isn't signed in.
///
/// Premium is account-tied — they need an account before they can purchase —
/// so this replaces the buy button and nudges them to sign in first.
struct PaywallAuthGate: View {
    /// Called when the user taps either CTA — the parent presents AuthView.
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Create a free account to purchase Premium and unlock it on all your devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button(action: onSignIn) {
                Text("Create Account to Unlock")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            }

            Button("Already have an account? Sign In", action: onSignIn)
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)

            Text("One-time purchase · No subscription · No expiry")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

#Preview {
    PaywallAuthGate(onSignIn: {})
}

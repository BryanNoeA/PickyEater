import SwiftUI

// V2 — NOT YET IMPLEMENTED
// Architecture for V2:
//   FeedMeViewModel (@Observable) → step-by-step: mood → dietary → budget → groupSize → result
//   AnthropicService → claude-haiku-4-5-20251001, prompt caching, structured JSON output
//   API key: server-side proxy only (e.g. Cloudflare Worker) — never embed client-side

struct FeedMeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Top row: drag handle + Done ───────────────────────────
                ZStack {
                    Capsule()
                        .fill(Color(.tertiaryLabel))
                        .frame(width: 36, height: 5)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Spacer()
                        Button("Done") { dismiss() }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)

                Spacer(minLength: 60)

                // ── Hero ──────────────────────────────────────────────────
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.08))
                            .frame(width: 108, height: 108)
                        Text("🤖")
                            .font(.system(size: 58))
                            .accessibilityHidden(true)
                    }

                    VStack(spacing: 6) {
                        Text("Feed Me")
                            .font(.system(size: 32, weight: .bold, design: .serif))

                        Text("Coming in V2")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }

                    Text("Tell our AI what you're in the mood for and it'll pick a restaurant and something to order — just for you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }

                Spacer(minLength: 48)

                // ── Preview steps ─────────────────────────────────────────
                VStack(spacing: 12) {
                    previewStep(icon: "🌤️", label: "What's your vibe today?")
                    previewStep(icon: "🥦", label: "Any dietary restrictions?")
                    previewStep(icon: "💸", label: "What's your budget?")
                    previewStep(icon: "👥", label: "Solo or a group?")
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 48)
            }
        }
        .background(Color.peBackground)
        .presentationBackground(Color.peBackground)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }

    private func previewStep(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Text(icon)
                .font(.system(size: 22))
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.08), in: Circle())
                .accessibilityHidden(true)

            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(0.6)
    }
}

#Preview {
    Color.peBackground.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            FeedMeView()
        }
}

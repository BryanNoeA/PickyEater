import SwiftUI

// V2 — NOT YET IMPLEMENTED
// Architecture for V2:
//   FeedMeViewModel (@Observable) → step-by-step: mood → dietary → budget → groupSize → result
//   AnthropicService → claude-haiku-4-5-20251001, prompt caching, structured JSON output
//   API key: server-side proxy only (Cloudflare Worker / Supabase Edge Function)

struct FeedMeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Text("🤖")
                        .font(.system(size: 52))
                        .accessibilityHidden(true)
                }

                VStack(spacing: 8) {
                    Text("Feed Me")
                        .font(.system(size: 28, weight: .black))
                    Text("Coming in V2")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }

                Text("Tell our AI what you're in the mood for and it'll pick a restaurant and something to order — just for you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .navigationTitle("Feed Me")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FeedMeView()
}

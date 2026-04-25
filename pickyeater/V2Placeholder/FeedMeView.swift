import SwiftUI

// V2 — NOT YET IMPLEMENTED
// Architecture:
//   FeedMeView → FeedMeViewModel (@Observable)
//     - messages: [ChatMessage]
//     - currentStep: FeedMeStep (mood → dietary → budget → groupSize → result)
//     - func sendMessage() → calls AnthropicService
//
//   AnthropicService
//     - Model: claude-haiku-4-5-20251001 (fast + low cost for conversational)
//     - System prompt cached as prefix block (prompt caching ~90% cost reduction)
//     - Structured JSON output: { restaurant: String, menuItem: String, reasoning: String }
//     - API key: NEVER embed in app — proxy through Cloudflare Worker or Supabase Edge Function
//     - AnthropicService(baseURL: URL) — configurable for proxy swap

struct FeedMeView: View {
    @Environment(AppState.self) private var appState
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

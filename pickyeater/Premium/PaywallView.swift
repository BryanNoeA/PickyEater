import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    featureList
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    ctaSection
                }
            }
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .onChange(of: storeKit.isPurchased) { _, purchased in
            if purchased { dismiss() }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 110, height: 110)
                Text("📍")
                    .font(.system(size: 52))
                    .accessibilityHidden(true)
            }
            .padding(.top, 32)

            Text("Picky Eater Premium")
                .font(.system(size: 28, weight: .black))

            Text("Find real restaurants near you after every spin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 16) {
            featureRow(icon: "mappin.and.ellipse", color: .red,
                       title: "Nearby Restaurants",
                       description: "See real places matching your spin result")
            featureRow(icon: "arrow.triangle.turn.up.right.diamond.fill", color: .blue,
                       title: "One-Tap Directions",
                       description: "Open Apple Maps directly to your restaurant")
            featureRow(icon: "infinity", color: .orange,
                       title: "Unlock Forever",
                       description: "One-time purchase, no subscription")
        }
        .padding(.horizontal, 24)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.purchase(storeKit: storeKit) }
            } label: {
                Group {
                    if viewModel.isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(storeKit.product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Premium")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.isPurchasing || viewModel.isRestoring)
            .accessibilityLabel(storeKit.product.map { "Unlock Premium for \($0.displayPrice)" } ?? "Unlock Premium")

            Button {
                Task { await viewModel.restore(storeKit: storeKit) }
            } label: {
                Group {
                    if viewModel.isRestoring {
                        ProgressView()
                    } else {
                        Text("Restore Purchase")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(viewModel.isPurchasing || viewModel.isRestoring)

            Text("One-time purchase · No subscription · No expiry")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold))
                Text(description).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreKitManager())
}

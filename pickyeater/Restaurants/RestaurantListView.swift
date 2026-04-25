import SwiftUI
import MapKit

struct RestaurantListView: View {
    let category: FoodCategory
    @State private var viewModel = RestaurantViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.restaurants.isEmpty {
                emptyView
            } else {
                restaurantList
            }
        }
        .onAppear {
            viewModel.requestLocation()
        }
        .onChange(of: viewModel.currentLocation) { _, _ in
            Task { await viewModel.search(for: category) }
        }
        .onChange(of: viewModel.locationError) { _, error in
            if let error { viewModel.errorMessage = error }
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                Text("Finding nearby \(category.displayName)…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }

    private func errorView(_ message: String) -> some View {
        Label(message, systemImage: "location.slash")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 12)
    }

    private var emptyView: some View {
        Label("No \(category.displayName) restaurants found nearby.", systemImage: "magnifyingglass")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 12)
    }

    private var restaurantList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.restaurants.enumerated()), id: \.offset) { index, item in
                if let location = viewModel.currentLocation {
                    RestaurantRowView(mapItem: item, userLocation: location)
                    if index < viewModel.restaurants.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    RestaurantListView(category: .sushi)
        .padding()
}

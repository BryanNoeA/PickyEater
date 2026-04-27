import SwiftUI
import MapKit

struct RestaurantListView: View {
    let category: FoodCategory
    @State private var viewModel = RestaurantViewModel()
    @Environment(FilterSettings.self) private var filterSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Open Now hint — MapKit can't filter by live hours, so we tell
            // the user to tap through to Maps to verify before heading out.
            if filterSettings.openNow && !viewModel.restaurants.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.caption)
                    Text("Hours not verified — tap any result to check in Maps.")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            }

            if viewModel.isLoading {
                RestaurantLoadingView(categoryName: category.displayName)
            } else if let error = viewModel.errorMessage {
                RestaurantErrorView(message: error)
            } else if viewModel.restaurants.isEmpty {
                RestaurantEmptyView(categoryName: category.displayName)
            } else if let location = viewModel.currentLocation {
                RestaurantListContent(restaurants: viewModel.restaurants, userLocation: location)
            }
        }
        .task {
            viewModel.requestLocation()
        }
        .onChange(of: viewModel.currentLocation) { _, _ in
            Task { await viewModel.search(for: category, radiusMeters: filterSettings.radiusMeters) }
        }
        .onChange(of: viewModel.locationError) { _, error in
            if let error { viewModel.errorMessage = error }
        }
        // Re-run the search whenever the radius slider changes
        .onChange(of: filterSettings.radiusMiles) { _, _ in
            Task { await viewModel.search(for: category, radiusMeters: filterSettings.radiusMeters) }
        }
    }
}

#Preview {
    RestaurantListView(category: .sushi)
        .environment(FilterSettings())
        .padding()
}

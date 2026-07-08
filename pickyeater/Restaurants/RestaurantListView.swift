import SwiftUI
import MapKit

struct RestaurantListView: View {
    let category: FoodCategory
    @State private var viewModel = RestaurantViewModel()
    @Environment(FilterSettings.self) private var filterSettings

    /// The error to show, whichever fired first — location or search.
    private var displayedError: String? {
        viewModel.errorMessage ?? viewModel.locationError
    }

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

            // Still resolving GPS/permission with no error yet — don't flash
            // the empty state before we've had a chance to search at all.
            if viewModel.isLoading || (viewModel.currentLocation == nil && displayedError == nil) {
                RestaurantLoadingView(categoryName: category.displayName)
            } else if let error = displayedError {
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
        // Single cancellable task keyed on location + radius — SwiftUI cancels
        // the in-flight search automatically when either changes, so a slow
        // stale MKLocalSearch can never overwrite a fresher result.
        .task(id: SearchKey(location: viewModel.currentLocation, radiusMiles: filterSettings.radiusMiles)) {
            guard viewModel.currentLocation != nil else { return }
            await viewModel.search(for: category, radiusMeters: filterSettings.radiusMeters)
        }
    }
}

/// Identifies a search request by the inputs that should trigger a new one.
/// Compares on coordinate rather than CLLocation identity so repeated GPS
/// fixes at (roughly) the same spot don't spawn a search for a no-op change.
private struct SearchKey: Equatable {
    let location: CLLocation?
    let radiusMiles: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.location?.coordinate.latitude == rhs.location?.coordinate.latitude
            && lhs.location?.coordinate.longitude == rhs.location?.coordinate.longitude
            && lhs.radiusMiles == rhs.radiusMiles
    }
}

#Preview {
    RestaurantListView(category: .sushi)
        .environment(FilterSettings())
        .padding()
}

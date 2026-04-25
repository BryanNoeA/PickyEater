import SwiftUI
import MapKit
import CoreLocation

struct RestaurantListView: View {
    let category: FoodCategory

    @State private var locationManager = LocationManager()
    @State private var restaurants: [MKMapItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if restaurants.isEmpty {
                emptyView
            } else {
                restaurantList
            }
        }
        .onAppear {
            locationManager.requestLocationIfNeeded()
        }
        .onChange(of: locationManager.currentLocation) { _, location in
            if let location {
                Task { await loadRestaurants(near: location) }
            }
        }
        .onChange(of: locationManager.locationError) { _, error in
            if let error {
                errorMessage = error
            }
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
            ForEach(Array(restaurants.enumerated()), id: \.offset) { index, item in
                if let location = locationManager.currentLocation {
                    RestaurantRowView(mapItem: item, userLocation: location)
                    if index < restaurants.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func loadRestaurants(near location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        do {
            restaurants = try await RestaurantSearchService.search(for: category, near: location)
        } catch {
            errorMessage = "Couldn't load restaurants. Check your connection and try again."
        }
        isLoading = false
    }
}

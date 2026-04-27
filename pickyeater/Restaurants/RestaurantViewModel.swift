import MapKit
import CoreLocation

/// Drives the restaurant-list feature.
///
/// Owns a LocationManager and coordinates between it and the search service.
/// Views read the published state (restaurants, isLoading, errorMessage) and
/// call requestLocation() to kick off the flow.
@Observable
final class RestaurantViewModel {
    // MARK: - Published state

    /// Results from the last MKLocalSearch call.
    var restaurants: [MKMapItem] = []

    /// True while a search request is in flight.
    var isLoading: Bool = false

    /// Set when location or search fails. Displayed to the user.
    var errorMessage: String? = nil

    // MARK: - Private

    private let locationManager = LocationManager()

    // MARK: - Forwarded location state
    // These computed properties let views observe location state without
    // holding a direct reference to LocationManager.

    var currentLocation: CLLocation? { locationManager.currentLocation }
    var locationError: String? { locationManager.locationError }
    var authorizationStatus: CLAuthorizationStatus { locationManager.authorizationStatus }

    // MARK: - Actions

    /// Ask for location permission (if needed) and request a one-shot GPS fix.
    /// Called once when the RestaurantListView appears.
    func requestLocation() {
        locationManager.requestLocationIfNeeded()
    }

    /// Run a MapKit search for the given category near the user's current location.
    /// No-ops if we don't have a location yet.
    /// - Parameter radiusMeters: Search radius — convert miles to metres before passing.
    func search(for category: FoodCategory, radiusMeters: Double = 16093.44) async {
        guard let location = locationManager.currentLocation else { return }

        isLoading = true
        errorMessage = nil

        do {
            restaurants = try await RestaurantSearchService.search(
                for: category,
                near: location,
                radiusMeters: radiusMeters
            )
        } catch {
            errorMessage = "Couldn't load restaurants. Check your connection and try again."
        }

        isLoading = false
    }
}

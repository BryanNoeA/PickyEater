import MapKit
import CoreLocation

/// Sends a MapKit local search request and returns up to 10 nearby restaurants
/// matching the given food category within a configurable radius.
struct RestaurantSearchService {
    static func search(
        for category: FoodCategory,
        near location: CLLocation,
        radiusMeters: Double = 2000   // ~1.25 miles
    ) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()

        // naturalLanguageQuery drives the Apple Maps search — e.g. "sushi restaurant"
        request.naturalLanguageQuery = category.searchTerm
        request.resultTypes = .pointOfInterest

        // Restrict results to a square region centred on the user's location
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusMeters,
            longitudinalMeters: radiusMeters
        )

        let response = try await MKLocalSearch(request: request).start()

        // Limit to 10 results so the list stays readable
        return Array(response.mapItems.prefix(10))
    }
}

// MARK: - MKMapItem helpers

extension MKMapItem {

    /// Straight-line distance from the user's location, formatted as miles.
    /// Shows "< 0.1 mi" for anything under a tenth of a mile.
    func distanceString(from location: CLLocation) -> String {
        // MKMapItem.placemark is deprecated in iOS 26; use the new .location
        // property (a CLLocation) to get the coordinate without a warning.
        let coord: CLLocationCoordinate2D
        if #available(iOS 26, *) {
            coord = self.location.coordinate
        } else {
            coord = placemark.coordinate
        }

        let meters = location.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
        let miles  = meters / 1609.344
        return miles < 0.1 ? "< 0.1 mi" : String(format: "%.1f mi", miles)
    }

    /// Short street address for display in a list row.
    /// Returns the street name if available, then city, then state.
    ///
    /// ⚠️ `MKMapItem.placemark` is deprecated in iOS 26, but Apple has not yet
    /// documented a replacement for reading address components from `MKLocalSearch`
    /// results. All access is consolidated here so it can be updated in one place
    /// once a proper replacement API is available.
    var addressLine: String {
        let pm = placemark  // single deprecated-property access — see note above
        return pm.thoroughfare          // street name, e.g. "Market St"
            ?? pm.locality             // city, e.g. "San Francisco"
            ?? pm.administrativeArea   // state, e.g. "CA"
            ?? ""
    }
}

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
        // Deployment target is iOS 26+, so `.location` (the non-deprecated
        // replacement for `.placemark.coordinate`) is always available.
        let meters = location.distance(from: self.location)
        let miles  = meters / 1609.344
        return miles < 0.1 ? "< 0.1 mi" : String(format: "%.1f mi", miles)
    }

    /// Short street address for display in a list row.
    /// Returns the short address (typically street name) if available,
    /// then falls back to city, then state.
    var addressLine: String {
        address?.shortAddress
            ?? addressRepresentations?.cityName          // city, e.g. "San Francisco"
            ?? addressRepresentations?.regionName         // state/region, e.g. "California"
            ?? ""
    }
}

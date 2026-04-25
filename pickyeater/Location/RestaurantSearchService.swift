import MapKit
import CoreLocation

struct RestaurantSearchService {
    static func search(
        for category: FoodCategory,
        near location: CLLocation,
        radiusMeters: Double = 2000
    ) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.searchTerm
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusMeters,
            longitudinalMeters: radiusMeters
        )
        let response = try await MKLocalSearch(request: request).start()
        return Array(response.mapItems.prefix(10))
    }
}

extension MKMapItem {
    func distanceString(from location: CLLocation) -> String {
        let coord: CLLocationCoordinate2D
        if #available(iOS 26, *) {
            coord = self.location.coordinate
        } else {
            coord = placemark.coordinate
        }
        let itemLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let meters = location.distance(from: itemLocation)
        let miles = meters / 1609.344
        if miles < 0.1 { return "< 0.1 mi" }
        return String(format: "%.1f mi", miles)
    }
}

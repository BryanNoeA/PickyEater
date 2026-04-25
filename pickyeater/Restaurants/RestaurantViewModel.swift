import MapKit
import CoreLocation

@Observable
final class RestaurantViewModel {
    var restaurants: [MKMapItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let locationManager = LocationManager()

    var currentLocation: CLLocation? { locationManager.currentLocation }
    var locationError: String? { locationManager.locationError }
    var authorizationStatus: CLAuthorizationStatus { locationManager.authorizationStatus }

    func requestLocation() {
        locationManager.requestLocationIfNeeded()
    }

    func search(for category: FoodCategory) async {
        guard let location = locationManager.currentLocation else { return }
        isLoading = true
        errorMessage = nil
        do {
            restaurants = try await RestaurantSearchService.search(for: category, near: location)
        } catch {
            errorMessage = "Couldn't load restaurants. Check your connection and try again."
        }
        isLoading = false
    }

    func onLocationUpdated(category: FoodCategory) async {
        if locationManager.currentLocation != nil {
            await search(for: category)
        }
        if let error = locationManager.locationError {
            errorMessage = error
        }
    }
}

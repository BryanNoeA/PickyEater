import CoreLocation

/// Wraps CLLocationManager and exposes observable state for SwiftUI.
///
/// We request "when in use" authorization only — and only when the user
/// enters the premium restaurant flow, never at app launch.
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    /// The most recent GPS fix. Nil until the user grants permission and a
    /// location is returned.
    var currentLocation: CLLocation? = nil

    /// Human-readable error string set when location cannot be obtained.
    var locationError: String? = nil

    /// Mirrors CLLocationManager.authorizationStatus so views can react to
    /// permission changes without directly importing CoreLocation.
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self

        // Hundred-metre accuracy is plenty for finding nearby restaurants
        // and uses less battery than kCLLocationAccuracyBest.
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // Read the current status immediately so we don't show a stale value
        // if the user has already granted or denied permission.
        authorizationStatus = manager.authorizationStatus
    }

    /// Requests location if we have permission, or asks for permission if
    /// this is the first time. Does nothing if already denied.
    func requestLocationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            // Triggers the iOS permission dialog (first time only)
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            // We already have permission — fire a one-shot location request.
            // The result arrives in locationManager(_:didUpdateLocations:).
            manager.requestLocation()

        case .denied, .restricted:
            locationError = "Location access is disabled. Enable it in Settings to find nearby restaurants."

        @unknown default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // `locations` is newest-last; we want the most recent fix.
        currentLocation = locations.last
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationError = "Unable to determine your location."
    }

    /// Called when the user changes the permission in Settings while the app
    /// is running, or immediately after requestWhenInUseAuthorization() resolves.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        // If the user just granted permission, fetch a location right away
        // so the restaurant list populates without requiring another tap.
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

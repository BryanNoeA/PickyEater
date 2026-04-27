import Foundation

/// Persisted filter preferences for the restaurant search.
///
/// Injected into the SwiftUI environment at app level so any view
/// (RestaurantListView, FilterView, SpinnerView badge) can read or
/// write settings without prop-drilling.
@Observable
final class FilterSettings {

    // MARK: - Preferences

    /// When true the user expects only open places.
    /// MapKit doesn't expose live hours, so this drives a UI hint
    /// rather than actual server-side filtering.
    var openNow: Bool = false {
        didSet { UserDefaults.standard.set(openNow, forKey: "filter_openNow") }
    }

    /// Search radius in miles. Range: 5–30, default 10.
    var radiusMiles: Double = 10 {
        didSet { UserDefaults.standard.set(radiusMiles, forKey: "filter_radiusMiles") }
    }

    // MARK: - Init

    init() {
        openNow     = UserDefaults.standard.bool(forKey: "filter_openNow")
        let saved   = UserDefaults.standard.double(forKey: "filter_radiusMiles")
        radiusMiles = saved > 0 ? saved : 10
    }

    // MARK: - Derived

    /// Radius converted to metres for MKCoordinateRegion.
    var radiusMeters: Double { radiusMiles * 1609.344 }

    /// True when any setting differs from its default — used to badge the filter button.
    var isActive: Bool { openNow || radiusMiles != 10 }

    /// Restores all settings to their defaults.
    func reset() {
        openNow     = false
        radiusMiles = 10
    }
}

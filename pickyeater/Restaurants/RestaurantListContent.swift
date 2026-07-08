import SwiftUI
import MapKit

struct RestaurantListContent: View {
    let restaurants: [MKMapItem]
    let userLocation: CLLocation

    var body: some View {
        VStack(spacing: 0) {
            ForEach(restaurants, id: \.rowID) { item in
                RestaurantRowView(mapItem: item, userLocation: userLocation)
                if item !== restaurants.last {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private extension MKMapItem {
    /// Stable identity for ForEach so search-result reordering doesn't
    /// scramble row identity/animations the way index-keying does.
    /// Falls back to name+coordinate when MapKit's identifier is nil
    /// (e.g. manually built MKMapItems in previews).
    var rowID: String {
        if let identifier {
            return identifier.rawValue
        }
        return "\(name ?? "")-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
    }
}

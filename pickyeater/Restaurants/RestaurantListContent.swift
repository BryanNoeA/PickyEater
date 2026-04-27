import SwiftUI
import MapKit

struct RestaurantListContent: View {
    let restaurants: [MKMapItem]
    let userLocation: CLLocation

    var body: some View {
        VStack(spacing: 0) {
            ForEach(restaurants.indices, id: \.self) { index in
                RestaurantRowView(mapItem: restaurants[index], userLocation: userLocation)
                if index < restaurants.count - 1 {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

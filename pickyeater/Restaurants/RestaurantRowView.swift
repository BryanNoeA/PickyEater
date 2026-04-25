import SwiftUI
import MapKit
import CoreLocation

struct RestaurantRowView: View {
    let mapItem: MKMapItem
    let userLocation: CLLocation

    var body: some View {
        Button {
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
            ])
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "fork.knife")
                        .foregroundStyle(Color.accentColor)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Restaurant")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(addressLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(mapItem.distanceString(from: userLocation))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .accessibilityLabel("\(mapItem.name ?? "Restaurant"), \(mapItem.distanceString(from: userLocation)) away")
        .accessibilityHint("Opens directions in Maps")
    }

    private var addressLine: String {
        mapItem.placemark.thoroughfare ?? mapItem.placemark.locality ?? mapItem.placemark.administrativeArea ?? ""
    }
}

#Preview {
    let item = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: 37.7749, longitude: -122.4194)))
    item.name = "Nobu San Francisco"
    return RestaurantRowView(
        mapItem: item,
        userLocation: CLLocation(latitude: 37.7849, longitude: -122.4094)
    )
    .padding()
}

import SwiftUI
import MapKit
import CoreLocation

private func addressLine(for item: MKMapItem) -> String {
    // placemark deprecated in iOS 26 but still functional; address API available in future update
    let placemark = item.placemark
    return placemark.thoroughfare ?? placemark.locality ?? placemark.administrativeArea ?? ""
}

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

                    Text(addressLine(for: mapItem))
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
    }
}

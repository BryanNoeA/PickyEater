import SwiftUI
import MapKit
import CoreLocation

/// A single row in the nearby-restaurants list.
/// Tapping it opens the place in Apple Maps with directions pre-loaded.
struct RestaurantRowView: View {
    let mapItem: MKMapItem
    let userLocation: CLLocation

    var body: some View {
        Button(action: openInMaps) {
            HStack(spacing: 12) {
                // Icon badge
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "fork.knife")
                        .foregroundStyle(Color.accentColor)
                        .font(.system(size: 16))
                }

                // Restaurant name + street address
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Restaurant")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    // addressLine is a computed property on MKMapItem (RestaurantSearchService.swift).
                    // It returns street → city → state, whichever is available first.
                    Text(mapItem.addressLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Distance + external-link chevron
                VStack(alignment: .trailing, spacing: 2) {
                    Text(mapItem.distanceString(from: userLocation))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            // Make the whole row tappable, not just the text
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .accessibilityLabel("\(mapItem.name ?? "Restaurant"), \(mapItem.distanceString(from: userLocation)) away")
        .accessibilityHint("Opens directions in Maps")
    }

    // MARK: - Actions

    private func openInMaps() {
        // MKLaunchOptionsDirectionsModeDefault lets Maps pick driving, walking,
        // or transit based on the user's last preference.
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ])
    }
}

#Preview {
    let item = MKMapItem(location: CLLocation(latitude: 37.7749, longitude: -122.4194), address: nil)
    item.name = "Nobu San Francisco"
    return RestaurantRowView(
        mapItem: item,
        userLocation: CLLocation(latitude: 37.7849, longitude: -122.4094)
    )
    .padding()
}

import SwiftUI
import CoreLocation

struct PlaceListView: View {
    let places: [Place]
    let userLocation: CLLocation?
    @Binding var selectedPlace: Place?

    var body: some View {
        if places.isEmpty {
            EmptyPlacesView()
        } else {
            List(places) { place in
                PlaceRowView(place: place, userLocation: userLocation)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedPlace = place }
                    .listRowBackground(
                        selectedPlace?.id == place.id
                            ? Color.blue.opacity(0.08)
                            : Color(.systemBackground)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}

struct PlaceRowView: View {
    let place: Place
    let userLocation: CLLocation?

    var distanceText: String? {
        guard let userLocation else { return nil }
        let placeLocation = CLLocation(latitude: place.coordinate.latitude,
                                       longitude: place.coordinate.longitude)
        let dist = userLocation.distance(from: placeLocation)
        return dist < 1000
            ? String(format: "%.0f m", dist)
            : String(format: "%.1f km", dist / 1000)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                if !place.address.isEmpty {
                    Text(place.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text(place.categoryLabel)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }

            Spacer()

            if let dist = distanceText {
                Text(dist)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct EmptyPlacesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "mappin.slash")
                .font(.system(size: 52))
                .foregroundColor(.secondary)
            Text("No Places Found")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Try selecting a different category or tap the refresh button.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

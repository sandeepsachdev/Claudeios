import SwiftUI
import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct NearbyMapView: View {
    let places: [Place]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedPlace: Place?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var hasSetInitialRegion = false

    var body: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: places) { place in
            MapAnnotation(coordinate: place.coordinate) {
                PlacePinView(place: place, isSelected: selectedPlace?.id == place.id)
                    .onTapGesture { selectedPlace = place }
            }
        }
        .onChange(of: userLocation) { newLocation in
            guard let loc = newLocation, !hasSetInitialRegion else { return }
            hasSetInitialRegion = true
            withAnimation {
                region = MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            }
        }
    }
}

struct PlacePinView: View {
    let place: Place
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.orange)
                    .frame(width: isSelected ? 46 : 34, height: isSelected ? 46 : 34)
                    .shadow(color: .black.opacity(0.25), radius: isSelected ? 6 : 3)
                Image(systemName: "mappin")
                    .font(.system(size: isSelected ? 20 : 15, weight: .bold))
                    .foregroundColor(.white)
            }
            if isSelected {
                Text(place.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .fixedSize()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

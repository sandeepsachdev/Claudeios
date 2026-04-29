import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion

    init(place: Place) {
        self.place = place
        _region = State(initialValue: MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Map(coordinateRegion: $region, annotationItems: [place]) { p in
                        MapMarker(coordinate: p.coordinate, tint: .orange)
                    }
                    .frame(height: 220)
                    .allowsHitTesting(false)

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(place.categoryLabel)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        if !place.address.isEmpty {
                            DetailRow(icon: "location.fill", color: .red,
                                      title: "Address", value: place.address)
                        }

                        if let phone = place.phoneNumber {
                            Button {
                                let digits = phone.filter { "0123456789+".contains($0) }
                                if let url = URL(string: "tel:\(digits)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                DetailRow(icon: "phone.fill", color: .green,
                                          title: "Phone", value: phone, tappable: true)
                            }
                            .buttonStyle(.plain)
                        }

                        if let url = place.url {
                            Button { UIApplication.shared.open(url) } label: {
                                DetailRow(icon: "globe", color: .blue,
                                          title: "Website",
                                          value: url.host ?? url.absoluteString,
                                          tappable: true)
                            }
                            .buttonStyle(.plain)
                        }

                        Divider()

                        Button {
                            place.mapItem.openInMaps(launchOptions: [
                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                            ])
                        } label: {
                            Label("Open in Maps", systemImage: "map.fill")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    var tappable: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(tappable ? .blue : .primary)
            }
            Spacer()
            if tappable {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

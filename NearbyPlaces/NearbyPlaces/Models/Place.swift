import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem

    var name: String { mapItem.name ?? "Unknown" }
    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }

    var address: String {
        let p = mapItem.placemark
        var parts: [String] = []
        if let street = p.thoroughfare { parts.append(street) }
        if let city = p.locality { parts.append(city) }
        return parts.joined(separator: ", ")
    }

    var phoneNumber: String? { mapItem.phoneNumber }
    var url: URL? { mapItem.url }

    var categoryLabel: String {
        mapItem.pointOfInterestCategory?.rawValue
            .components(separatedBy: ".")
            .last?
            .capitalized ?? "Place"
    }
}

import SwiftUI
import MapKit

enum PlaceCategory: String, CaseIterable, Identifiable {
    case restaurants = "Restaurants"
    case cafes = "Cafes"
    case parks = "Parks"
    case museums = "Museums"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bars = "Bars"

    var id: String { rawValue }

    var mkCategories: [MKPointOfInterestCategory] {
        switch self {
        case .restaurants:   return [.restaurant]
        case .cafes:         return [.cafe]
        case .parks:         return [.park, .nationalPark]
        case .museums:       return [.museum]
        case .shopping:      return [.store]
        case .entertainment: return [.movieTheater, .theater, .amusementPark]
        case .bars:          return [.nightlife]
        }
    }

    var icon: String {
        switch self {
        case .restaurants:   return "fork.knife"
        case .cafes:         return "cup.and.saucer.fill"
        case .parks:         return "leaf.fill"
        case .museums:       return "building.columns.fill"
        case .shopping:      return "bag.fill"
        case .entertainment: return "film.fill"
        case .bars:          return "wineglass.fill"
        }
    }

    var color: Color {
        switch self {
        case .restaurants:   return .orange
        case .cafes:         return .brown
        case .parks:         return .green
        case .museums:       return .purple
        case .shopping:      return .pink
        case .entertainment: return .red
        case .bars:          return .indigo
        }
    }
}

class PlacesSearchManager: ObservableObject {
    @Published var places: [Place] = []
    @Published var isSearching = false

    private var currentSearch: MKLocalSearch?

    func searchNearby(location: CLLocation, category: PlaceCategory, radius: Double = 1500) {
        currentSearch?.cancel()
        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.rawValue
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category.mkCategories)
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )

        let search = MKLocalSearch(request: request)
        currentSearch = search
        search.start { [weak self] response, _ in
            DispatchQueue.main.async {
                self?.isSearching = false
                self?.places = response?.mapItems.map { Place(mapItem: $0) } ?? []
            }
        }
    }
}

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchManager = PlacesSearchManager()

    @State private var selectedCategory: PlaceCategory = .restaurants
    @State private var selectedPlace: Place?
    @State private var viewMode: ViewMode = .map
    @State private var showDetail = false

    enum ViewMode { case map, list }

    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("Nearby Places")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    toolbarContent
                }
                .onChange(of: selectedCategory) { _ in performSearch() }
                .onChange(of: locationManager.location) { newLoc in
                    guard searchManager.places.isEmpty, newLoc != nil else { return }
                    performSearch()
                }
                .onChange(of: selectedPlace) { place in
                    if place != nil { showDetail = true }
                }
                .sheet(isPresented: $showDetail, onDismiss: { selectedPlace = nil }) {
                    if let place = selectedPlace {
                        PlaceDetailView(place: place)
                    }
                }
                .onAppear {
                    locationManager.requestPermission()
                }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            CategoryFilterView(selectedCategory: $selectedCategory)
                .background(Color(.systemBackground))

            Divider()

            contentArea
        }
    }
    
    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            viewContent
            
            if searchManager.isSearching {
                searchingOverlay
            }

            if locationManager.authorizationStatus == .denied ||
               locationManager.authorizationStatus == .restricted {
                LocationPermissionView()
            }
        }
    }
    
    @ViewBuilder
    private var viewContent: some View {
        if viewMode == .map {
            NearbyMapView(
                places: searchManager.places,
                userLocation: locationManager.location?.coordinate,
                selectedPlace: $selectedPlace
            )
            .ignoresSafeArea(edges: .bottom)
        } else {
            PlaceListView(
                places: searchManager.places,
                userLocation: locationManager.location,
                selectedPlace: $selectedPlace
            )
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var searchingOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                ProgressView().tint(.white)
                Text("Searching nearby…")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.72))
            .cornerRadius(22)
            .padding(.bottom, 24)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: performSearch) {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(locationManager.location == nil)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Picker("View Mode", selection: $viewMode) {
                Image(systemName: "map").tag(ViewMode.map)
                Image(systemName: "list.bullet").tag(ViewMode.list)
            }
            .pickerStyle(.segmented)
            .frame(width: 84)
        }
    }

    private func performSearch() {
        guard let location = locationManager.location else { return }
        searchManager.searchNearby(location: location, category: selectedCategory)
    }
}

struct LocationPermissionView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 54))
                    .foregroundColor(.orange)
                Text("Location Access Required")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Enable location access in Settings to discover restaurants and activities near you.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 13)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
            }
            .padding(24)
        }
    }
}

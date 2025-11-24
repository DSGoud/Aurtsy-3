import SwiftUI
import MapKit

struct LocationCheckView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locationName = ""
    @State private var notes = ""
    @State private var showingCheckIn = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: networkManager.locationChecks) { check in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(check.latitude) ?? 0, longitude: Double(check.longitude) ?? 0)) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    }
                }
                .frame(height: 300)
                .cornerRadius(20)
                .padding()
                
                // Latest Location Info
                if let latest = networkManager.locationChecks.first {
                    VStack(alignment: .leading) {
                        Text("Latest Check-in")
                            .font(.headline)
                        Text(latest.locationName ?? "Unknown Location")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(latest.createdAt, style: .time)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                
                // Check In Button
                Button(action: { showingCheckIn = true }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Check In Now")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding()
                
                // History List
                List {
                    Section(header: Text("History")) {
                        ForEach(networkManager.locationChecks) { check in
                            VStack(alignment: .leading) {
                                Text(check.locationName ?? "Location Check")
                                    .font(.headline)
                                Text(check.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Location")
            .sheet(isPresented: $showingCheckIn) {
                NavigationView {
                    Form {
                        TextField("Location Name", text: $locationName)
                        TextField("Notes", text: $notes)
                    }
                    .navigationTitle("New Check-in")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingCheckIn = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Check In") {
                                checkIn()
                                showingCheckIn = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let child = networkManager.selectedChild {
                networkManager.fetchLocationChecks(childId: child.id)
            }
        }
    }
    
    func checkIn() {
        if let child = networkManager.selectedChild {
            // In real app, get actual GPS coordinates
            // For now, use the map center or random nearby point
            let lat = String(region.center.latitude)
            let lon = String(region.center.longitude)
            
            networkManager.createLocationCheck(
                childId: child.id,
                lat: lat,
                lon: lon,
                name: locationName.isEmpty ? "Current Location" : locationName,
                notes: notes
            )
            locationName = ""
            notes = ""
        }
    }
}

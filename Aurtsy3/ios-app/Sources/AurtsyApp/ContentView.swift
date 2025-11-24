import SwiftUI

struct ContentView: View {
    @StateObject private var network = NetworkManager.shared
    @State private var selectedTab = 0
    @State private var showMealEntry = false
    
    var body: some View {
        if network.currentUser == nil {
            LoginView()
        } else {
            TabView(selection: $selectedTab) {
                QuickLogDashboard(onOpenMealEntry: {
                    showMealEntry = true
                })
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(0)
                
                Text("History View Placeholder")
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .environmentObject(network)
            .sheet(isPresented: $showMealEntry) {
                MealEntryModal()
                    // Inject environment object if needed, or refactor MealEntryModal to use NetworkManager
            }
        }
    }
}

struct LoginView: View {
    @State private var userId = ""
    
    var body: some View {
        VStack {
            Text("Aurtsy Caregiver")
                .font(.largeTitle)
                .padding()
            
            TextField("User ID", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Login") {
                Task {
                    try? await NetworkManager.shared.login(userId: userId)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct DashboardView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent Activity")) {
                    Text("Breakfast - 8:00 AM")
                    Text("Playtime - 10:30 AM")
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct MealLogView: View {
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    // Open Camera
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                        
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                            Text("Take Photo")
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Log Meal")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}

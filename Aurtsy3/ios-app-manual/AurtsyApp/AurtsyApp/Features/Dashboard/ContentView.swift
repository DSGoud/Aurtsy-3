import SwiftUI

struct ContentView: View {
    @StateObject private var network = NetworkManager.shared
    @State private var selectedTab = 0
    @State private var showMealEntry = false
    
    var body: some View {
        if network.currentUser == nil {
            LoginView()
                .onAppear {
                    print("🔵 LoginView appeared - starting auto-login")
                    // Auto-login for testing
                    Task {
                        print("🔵 Logging in as test_user")
                        try? await network.login(userId: "test_user")
                        print("🔵 Login complete, fetching children")
                        network.fetchChildren()
                    }
                }
        } else {
            TabView(selection: $selectedTab) {
                QuickLogDashboard(onOpenMealEntry: {
                    showMealEntry = true
                })
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(1)
                
                // Insights Tab
                if let selectedChild = network.selectedChild {
                    InsightsView(childId: selectedChild.id)
                        .tabItem {
                            Label("Insights", systemImage: "chart.xyaxis.line")
                        }
                        .tag(2)
                } else {
                    Text("Select a child to view insights")
                        .tabItem {
                            Label("Insights", systemImage: "chart.xyaxis.line")
                        }
                        .tag(2)
                }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(3)
            }
            .environmentObject(network)
            .sheet(isPresented: $showMealEntry) {
                MealEntryModal()
                    .environmentObject(network)
            }
            .onAppear {
                network.fetchChildren()
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

import Foundation

@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // Change this to your Epyc server IP when running on device
    let baseURL = "http://100.79.130.75:8090"
    
    @Published var currentUser: User?
    
    @Published var hydrationLogs: [HydrationLog] = []
    @Published var dailyHydrationTotal: Int = 0
    
    @Published var behaviorLogs: [BehaviorLog] = []
    @Published var meals: [Meal] = []
    
    @Published var activityFeed: [FeedItem] = []
    @Published var isLoadingFeed = false
    
    
    func updateActivityFeed() {
        // Client-side aggregation of all logs into activity feed
        isLoadingFeed = true
        
        var items: [FeedItem] = []
        
        // Add meals
        for meal in meals {
            items.append(FeedItem(
                id: "meal-\(meal.id)",
                type: .meal,
                title: meal.mealType,
                subtitle: meal.notes ?? "Meal logged",
                date: meal.createdAt,
                icon: "fork.knife",
                color: .orange
            ))
        }
        
        // Add sleep logs
        for log in sleepLogs {
            items.append(FeedItem(
                id: "sleep-\(log.id)",
                type: .sleep,
                title: "Sleep Log",
                subtitle: log.endTime == nil ? "Started sleeping" : "Slept for \(log.durationMinutes ?? 0)m",
                date: log.startTime,
                icon: "bed.double.fill",
                color: .blue
            ))
        }
        
        // Add behavior logs
        for log in behaviorLogs {
            items.append(FeedItem(
                id: "behavior-\(log.id)",
                type: .behavior,
                title: log.behaviorType.capitalized,
                subtitle: log.incidentDescription ?? "Mood: \(log.moodRating ?? 0)/5",
                date: log.createdAt,
                icon: "brain.head.profile",
                color: .purple
            ))
        }
        
        // Add hydration logs
        for log in hydrationLogs {
            items.append(FeedItem(
                id: "hydration-\(log.id)",
                type: .hydration,
                title: "Hydration",
                subtitle: "\(log.amountMl)ml of \(log.fluidType)",
                date: log.createdAt,
                icon: "drop.fill",
                color: .cyan
            ))
        }
        
        // Add location checks
        for log in locationChecks {
            items.append(FeedItem(
                id: "location-\(log.id)",
                type: .location,
                title: "Location Check",
                subtitle: log.locationName ?? "Check-in recorded",
                date: log.createdAt,
                icon: "location.fill",
                color: .red
            ))
        }
        
        // Add activity logs
        for log in activityLogs {
            let duration = (log.details?["duration_minutes"] as? Int) ?? 0
            items.append(FeedItem(
                id: "activity-\(log.id)",
                type: .activity,
                title: log.activityType,
                subtitle: "\(duration) mins",
                date: log.createdAt,
                icon: "figure.walk",
                color: .green
            ))
        }
        
        // Sort by date descending
        let sortedItems = items.sorted { $0.date > $1.date }
        
        DispatchQueue.main.async {
            self.activityFeed = Array(sortedItems)
            self.isLoadingFeed = false
        }
    }
    
    // Helper to trigger feed update
    func fetchActivityFeed(childId: String) {
        // Just trigger an update based on current data
        updateActivityFeed()
    }
    
    private func processFeed(_ raw: RawActivityFeed) -> [FeedItem] {
        // Deprecated
        return []
    }

    @Published var locationChecks: [LocationCheck] = []
    
    @Published var activityLogs: [Activity] = []
    
    func fetchActivityLogs(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)/activities/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let logs = try decoder.decode([Activity].self, from: data)
                DispatchQueue.main.async {
                    self.activityLogs = logs
                    self.updateActivityFeed()
                }
            } catch {
                print("Error decoding activity logs: \(error)")
            }
        }.resume()
    }
    
    func createActivityLog(childId: String, type: String, duration: Int, notes: String) {
        guard let url = URL(string: "\(baseURL)/activities/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let details: [String: Any] = [
            "duration_minutes": duration,
            "notes": notes
        ]
        
        let body: [String: Any] = [
            "child_id": childId,
            "activity_type": type,
            "details": details
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { self.fetchActivityLogs(childId: childId) }
        }.resume()
    }

    func fetchLocationChecks(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)/location/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let checks = try decoder.decode([LocationCheck].self, from: data)
                DispatchQueue.main.async {
                    self.locationChecks = checks
                    self.updateActivityFeed()
                }
            } catch {
                print("Error decoding location checks: \(error)")
            }
        }.resume()
    }
    
    func createLocationCheck(childId: String, lat: String, lon: String, name: String, notes: String) {
        guard let url = URL(string: "\(baseURL)/location/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "child_id": childId,
            "latitude": lat,
            "longitude": lon,
            "location_name": name,
            "notes": notes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { self.fetchLocationChecks(childId: childId) }
        }.resume()
    }

    func login(userId: String) async throws {
        // For prototype, we just fetch the user by ID (simulating login)
        // In real app, use proper auth
        // This is a placeholder implementation
        let user = User(id: userId, email: "test@example.com", role: .parent, isActive: true)
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
    
    @Published var children: [Child] = []
    @Published var selectedChild: Child?
    
    func fetchChildren() {
        print("🔵 Fetching children from: \(baseURL)/children/")
        guard let url = URL(string: "\(baseURL)/children/") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 HTTP Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            print("🔵 Received data: \(String(data: data, encoding: .utf8) ?? "unable to decode")")
            
            do {
                let decodedChildren = try JSONDecoder().decode([Child].self, from: data)
                print("✅ Decoded \(decodedChildren.count) children")
                DispatchQueue.main.async {
                    self.children = decodedChildren
                    if self.selectedChild == nil, let first = decodedChildren.first {
                        self.selectedChild = first
                        print("✅ Auto-selected child: \(first.name)")
                    }
                }
            } catch {
                print("❌ Error decoding children: \(error)")
            }
        }.resume()
    }
    
    func createChild(name: String, birthdate: String) {
        guard let url = URL(string: "\(baseURL)/children/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "id": UUID().uuidString,
            "name": name,
            "birthdate": birthdate
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding child: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async { self.fetchChildren() }
            }
        }.resume()
    }
    
    func deleteChild(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async { self.fetchChildren() }
            }
        }.resume()
    }

    @Published var sleepLogs: [SleepLog] = []
    @Published var activeSleepLog: SleepLog?
    
    func fetchSleepLogs(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)/sleep/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let logs = try decoder.decode([SleepLog].self, from: data)
                DispatchQueue.main.async {
                    self.sleepLogs = logs
                    self.activeSleepLog = logs.first(where: { $0.endTime == nil })
                    self.updateActivityFeed()
                }
            } catch {
                print("Error decoding sleep logs: \(error)")
            }
        }.resume()
    }
    
    func createSleepLog(childId: String, startTime: Date) {
        guard let url = URL(string: "\(baseURL)/sleep/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "child_id": childId,
            "start_time": formatter.string(from: startTime)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let log = try decoder.decode(SleepLog.self, from: data)
                    DispatchQueue.main.async {
                        self.activeSleepLog = log
                        self.fetchSleepLogs(childId: childId)
                    }
                } catch { print(error) }
            }
        }.resume()
    }
    
    func updateSleepLog(logId: Int, endTime: Date, rating: Int, notes: String) {
        guard let url = URL(string: "\(baseURL)/sleep/\(logId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "end_time": formatter.string(from: endTime),
            "quality_rating": rating,
            "notes": notes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let child = self.selectedChild {
                    self.fetchSleepLogs(childId: child.id)
                }
            }
        }.resume()
    }
    
    func createManualSleepLog(childId: String, start: Date, end: Date, rating: Int, notes: String) {
        guard let url = URL(string: "\(baseURL)/sleep/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "child_id": childId,
            "start_time": formatter.string(from: start),
            "end_time": formatter.string(from: end),
            "quality_rating": rating,
            "notes": notes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { self.fetchSleepLogs(childId: childId) }
        }.resume()
    }
    
    // MARK: - Hydration
    
    func fetchHydrationLogs(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)/hydration/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let logs = try decoder.decode([HydrationLog].self, from: data)
                
                DispatchQueue.main.async {
                    self.hydrationLogs = logs
                    // Calculate daily total
                    let calendar = Calendar.current
                    let todayLogs = logs.filter { calendar.isDateInToday($0.createdAt) }
                    self.dailyHydrationTotal = todayLogs.reduce(0) { $0 + $1.amountMl }
                    self.updateActivityFeed()
                }
            } catch {
                print("Error decoding hydration logs: \(error)")
            }
        }.resume()
    }
    
    func createHydrationLog(childId: String, amount: Int, type: String, notes: String) {
        guard let url = URL(string: "\(baseURL)/hydration/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "child_id": childId,
            "amount_ml": amount,
            "fluid_type": type,
            "notes": notes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { self.fetchHydrationLogs(childId: childId) }
        }.resume()
    }
    
    // MARK: - Behavior
    
    func fetchBehaviorLogs(childId: String) {
        guard let url = URL(string: "\(baseURL)/children/\(childId)/behavior/") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // Custom date formatter to handle fractional seconds
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                let logs = try decoder.decode([BehaviorLog].self, from: data)
                DispatchQueue.main.async {
                    self.behaviorLogs = logs
                    self.updateActivityFeed()
                }
            } catch {
                print("Error decoding behavior logs: \(error)")
            }
        }.resume()
    }
    
    func createBehaviorLog(childId: String, type: String, mood: Int, description: String, notes: String) {
        guard let url = URL(string: "\(baseURL)/behavior/?user_id=\(currentUser?.id ?? "unknown")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "child_id": childId,
            "behavior_type": type,
            "mood_rating": mood,
            "incident_description": description,
            "notes": notes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { self.fetchBehaviorLogs(childId: childId) }
        }.resume()

    }

    func fetchMeals(childId: String) async throws -> [Meal] {
        print("🍽️ Fetching meals for child: \(childId)")
        guard let url = URL(string: "\(baseURL)/children/\(childId)/meals/") else {
            print("❌ Invalid meals URL")
            throw URLError(.badURL)
        }
        
        print("🍽️ Meals URL: \(url)")
        let (data, _) = try await URLSession.shared.data(from: url)
        print("🍽️ Received \(data.count) bytes of meal data")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Custom date formatter to handle fractional seconds in ISO8601
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        let fetchedMeals = try decoder.decode([Meal].self, from: data)
        
        print("🍽️ Decoded \(fetchedMeals.count) meals")
        
        // Update published var on main thread
        DispatchQueue.main.async {
            print("🍽️ Updating meals array and activity feed")
            self.meals = fetchedMeals
            self.updateActivityFeed()
            print("🍽️ Activity feed now has \(self.activityFeed.count) items")
        }
        
        return fetchedMeals
    }
    
    func uploadMeal(childId: String, type: String, notes: String) async throws {
        guard let url = URL(string: "\(baseURL)/meals/?user_id=\(currentUser?.id ?? "unknown")") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "child_id": childId,
            "meal_type": type,
            "notes": notes
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    // MARK: - AI Handoff
    
    struct HandoffSummary: Codable {
        let summary: [String]
        let alertLevel: String
        let recommendations: [String]
    }
    
    @Published var handoffSummary: HandoffSummary?
    
    func fetchHandoffSummary(childId: String) {
        guard let url = URL(string: "\(baseURL)/ai/handoff/\(childId)") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let summary = try decoder.decode(HandoffSummary.self, from: data)
                DispatchQueue.main.async {
                    self.handoffSummary = summary
                }
            } catch {
                print("Error decoding handoff summary: \(error)")
            }
        }.resume()
    }
    
    func processVoiceLog(childId: String, text: String) {
        guard let url = URL(string: "\(baseURL)/ai/process_log") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "child_id": childId,
            "user_id": currentUser?.id ?? "test_user",
            "text": text
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch { return }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            guard let self = self else { return }
            // After processing, refresh all relevant data
            DispatchQueue.main.async {
                Task {
                    try? await self.fetchMeals(childId: childId)
                }
                self.fetchBehaviorLogs(childId: childId)
                self.fetchSleepLogs(childId: childId)
                self.fetchActivityLogs(childId: childId)
                self.fetchHydrationLogs(childId: childId)
                // The activity feed will auto-update when these return
            }
        }.resume()
    }
}

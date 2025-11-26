import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var network: NetworkManager
    @State private var timeRange: TimeRange = .day
    
    enum TimeRange: String, CaseIterable {
        case fourHours = "4h"
        case twelveHours = "12h"
        case day = "24h"
        case week = "7d"
        
        var hours: Int {
            switch self {
            case .fourHours: return 4
            case .twelveHours: return 12
            case .day: return 24
            case .week: return 168
            }
        }
    }
    
    var filteredFeed: [FeedItem] {
        let cutoff = Date().addingTimeInterval(-Double(timeRange.hours) * 3600)
        return network.activityFeed.filter { $0.date >= cutoff }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Visualizations
                    if !filteredFeed.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Trends")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Mood Chart
                                    ChartCard(title: "Mood") {
                                        Chart {
                                            ForEach(network.behaviorLogs.filter { $0.createdAt >= Date().addingTimeInterval(-Double(timeRange.hours) * 3600) }) { log in
                                                if let mood = log.moodRating {
                                                    LineMark(
                                                        x: .value("Time", log.createdAt),
                                                        y: .value("Mood", mood)
                                                    )
                                                    .foregroundStyle(Color.purple)
                                                    .symbol(Circle())
                                                }
                                            }
                                        }
                                        .chartYScale(domain: 1...5)
                                    }
                                    
                                    // Sleep Chart
                                    ChartCard(title: "Sleep (hrs)") {
                                        Chart {
                                            ForEach(network.sleepLogs.filter { $0.startTime >= Date().addingTimeInterval(-Double(timeRange.hours) * 3600) }) { log in
                                                if let duration = log.durationMinutes {
                                                    BarMark(
                                                        x: .value("Time", log.startTime),
                                                        y: .value("Hours", Double(duration) / 60.0)
                                                    )
                                                    .foregroundStyle(Color.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Detailed List
                    VStack(alignment: .leading) {
                        Text("Detailed Logs")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            if filteredFeed.isEmpty {
                                Text("No activity in this time range")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(filteredFeed) { item in
                                    FeedItemRow(item: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("History")
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                print("📊 HistoryView appeared")
                if let child = network.selectedChild {
                    print("📊 Selected child: \(child.name) (ID: \(child.id))")
                    network.fetchActivityFeed(childId: child.id)
                    // Ensure we have raw logs for charts and feed
                    Task {
                        do {
                            print("📊 Starting to fetch meals...")
                            try await network.fetchMeals(childId: child.id)
                            print("📊 Meals fetch completed")
                        } catch {
                            print("❌ Error fetching meals: \(error)")
                        }
                    }
                    network.fetchBehaviorLogs(childId: child.id)
                    network.fetchSleepLogs(childId: child.id)
                } else {
                    print("❌ No child selected!")
                }
            }
        }
    }
    
    func refreshData() async {
        guard let child = network.selectedChild else { return }
        print("🔄 Refreshing History data...")
        
        try? await network.fetchMeals(childId: child.id)
        network.fetchBehaviorLogs(childId: child.id)
        network.fetchSleepLogs(childId: child.id)
        network.fetchActivityLogs(childId: child.id)
        network.fetchHydrationLogs(childId: child.id)
        
        print("✅ History refresh complete")
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            content
                .frame(height: 150)
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

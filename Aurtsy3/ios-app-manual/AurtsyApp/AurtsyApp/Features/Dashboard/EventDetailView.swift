import SwiftUI

struct EventDetailView: View {
    let item: FeedItem
    @EnvironmentObject var network: NetworkManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with icon and type
                HStack {
                    Image(systemName: item.icon)
                        .font(.largeTitle)
                        .foregroundColor(item.color)
                        .frame(width: 50, height: 50)
                        .background(item.color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.title2.bold())
                        Text(item.type.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Date & Time
                DetailRow(label: "Date", value: item.date.formatted(date: .long, time: .shortened))
                
                // Description/Notes from FeedItem
                if !item.subtitle.isEmpty {
                    DetailRow(label: "Summary", value: item.subtitle)
                }
                
                // Fetch full data from network based on type
                Group {
                    switch item.type {
                    case .meal:
                        MealDetailSection(mealId: extractId(from: item.id))
                    case .behavior:
                        BehaviorDetailSection(behaviorId: extractId(from: item.id))
                    case .sleep:
                        SleepDetailSection(sleepId: extractId(from: item.id))
                    default:
                        EmptyView()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func extractId(from itemId: String) -> Int {
        // Extract numeric ID from "meal-123", "behavior-45", etc.
        // Format is usually "type-id"
        let components = itemId.split(separator: "-")
        if let last = components.last, let id = Int(last) {
            return id
        }
        return 0
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - Type Specific Sections

struct MealDetailSection: View {
    let mealId: Int
    @EnvironmentObject var network: NetworkManager
    
    var meal: Meal? {
        network.meals.first { $0.id == mealId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let meal = meal {
                Divider()
                Text("Meal Details").font(.headline)
                
                DetailRow(label: "Meal Type", value: meal.mealType)
                
                if let notes = meal.notes {
                    DetailRow(label: "Notes", value: notes)
                }
                
                if let photoUrl = meal.photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                }
                
                DetailRow(label: "Analysis Status", value: meal.analysisStatus)
            } else {
                Text("Loading meal details...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BehaviorDetailSection: View {
    let behaviorId: Int
    @EnvironmentObject var network: NetworkManager
    
    var behavior: BehaviorLog? {
        network.behaviorLogs.first { $0.id == behaviorId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let behavior = behavior {
                Divider()
                Text("Behavior Analysis").font(.headline)
                
                DetailRow(label: "Behavior Type", value: behavior.behaviorType.capitalized)
                
                if let mood = behavior.moodRating {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOOD RATING")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= mood ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                
                if let description = behavior.incidentDescription {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ABC ANALYSIS / NOTES")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(description)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if let severity = behavior.severity {
                    DetailRow(label: "Severity", value: "\(severity)/5")
                }
            } else {
                Text("Loading behavior details...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SleepDetailSection: View {
    let sleepId: Int
    @EnvironmentObject var network: NetworkManager
    
    var sleep: SleepLog? {
        network.sleepLogs.first { $0.id == sleepId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let sleep = sleep {
                Divider()
                Text("Sleep Details").font(.headline)
                
                DetailRow(label: "Start Time", value: sleep.startTime.formatted(date: .omitted, time: .shortened))
                if let end = sleep.endTime {
                    DetailRow(label: "End Time", value: end.formatted(date: .omitted, time: .shortened))
                }
                
                if let duration = sleep.durationMinutes {
                    let hours = duration / 60
                    let mins = duration % 60
                    DetailRow(label: "Duration", value: "\(hours)h \(mins)m")
                }
                
                if let quality = sleep.qualityRating {
                    DetailRow(label: "Quality", value: "\(quality)/5")
                }
                
                if let notes = sleep.notes {
                    DetailRow(label: "Notes", value: notes)
                }
            }
        }
    }
}

import SwiftUI

struct BehaviorLogView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var showingAddLog = false
    @State private var selectedType = "MOOD"
    @State private var moodRating = 3
    @State private var description = ""
    @State private var severity = 1
    
    let behaviorTypes = ["MOOD", "INCIDENT", "MILESTONE"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(networkManager.behaviorLogs) { log in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(log.behaviorType)
                                .font(.headline)
                                .foregroundColor(colorForType(log.behaviorType))
                            Spacer()
                            Text(log.createdAt, style: .date)
                                .font(.caption)
                        }
                        
                        if let mood = log.moodRating {
                            HStack {
                                Text("Mood:")
                                ForEach(0..<mood, id: \.self) { _ in
                                    Image(systemName: "smiley.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                        if let desc = log.incidentDescription {
                            Text(desc)
                                .font(.body)
                                .padding(.top, 2)
                        }
                        
                        if let sev = log.severity {
                            HStack {
                                Text("Severity:")
                                ForEach(0..<sev, id: \.self) { _ in
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Behavior Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLog = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                NavigationView {
                    Form {
                        Section(header: Text("Type")) {
                            Picker("Type", selection: $selectedType) {
                                ForEach(behaviorTypes, id: \.self) { type in
                                    Text(type.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        if selectedType == "MOOD" {
                            Section(header: Text("Mood Rating")) {
                                Picker("Mood", selection: $moodRating) {
                                    ForEach(1...5, id: \.self) { rating in
                                        Text("\(rating)").tag(rating)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        
                        if selectedType == "INCIDENT" {
                            Section(header: Text("Severity")) {
                                Picker("Severity", selection: $severity) {
                                    ForEach(1...5, id: \.self) { level in
                                        Text("Level \(level)").tag(level)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Description")) {
                            TextEditor(text: $description)
                                .frame(height: 100)
                        }
                    }
                    .navigationTitle("Log Behavior")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddLog = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                addLog()
                                showingAddLog = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let child = networkManager.selectedChild {
                networkManager.fetchBehaviorLogs(childId: child.id)
            }
        }
    }
    
    func addLog() {
        if let child = networkManager.selectedChild {
            networkManager.createBehaviorLog(
                childId: child.id,
                type: selectedType,
                mood: selectedType == "MOOD" ? moodRating : 0,
                description: description,
                notes: selectedType == "INCIDENT" ? "Severity: \(severity)" : ""
            )
            description = ""
            moodRating = 3
            severity = 1
        }
    }
    
    func colorForType(_ type: String) -> Color {
        switch type {
        case "MOOD": return .green
        case "INCIDENT": return .red
        case "MILESTONE": return .purple
        default: return .primary
        }
    }
}

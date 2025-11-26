import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var showingAddLog = false
    @State private var selectedType = "Play"
    @State private var durationMinutes = 30
    @State private var notes = ""
    
    let activityTypes = ["Play", "Exercise", "Therapy", "School", "Other"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(networkManager.activityLogs) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.activityType)
                                .font(.headline)
                            Text("\(log.durationMinutes) minutes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let details = log.details, !details.isEmpty {
                                Text(details)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Text(log.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Activity Log")
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
                        Section(header: Text("Activity Type")) {
                            Picker("Type", selection: $selectedType) {
                                ForEach(activityTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                        }
                        
                        Section(header: Text("Duration (minutes)")) {
                            Stepper(value: $durationMinutes, in: 5...240, step: 5) {
                                Text("\(durationMinutes) min")
                            }
                        }
                        
                        Section(header: Text("Notes")) {
                            TextField("Details...", text: $notes)
                        }
                    }
                    .navigationTitle("Log Activity")
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
                networkManager.fetchActivityLogs(childId: child.id)
            }
        }
    }
    
    func addLog() {
        if let child = networkManager.selectedChild {
            networkManager.createActivityLog(
                childId: child.id,
                type: selectedType,
                duration: durationMinutes,
                notes: notes
            )
            notes = ""
            durationMinutes = 30
        }
    }
}

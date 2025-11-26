import SwiftUI

struct SleepLogView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var isTimerRunning = false
    @State private var startTime: Date?
    @State private var showingManualEntry = false
    @State private var manualStart = Date()
    @State private var manualEnd = Date()
    @State private var qualityRating = 3
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Timer Section
                VStack(spacing: 20) {
                    Text(isTimerRunning ? "Sleep Timer Active" : "Start Sleep Timer")
                        .font(.headline)
                    
                    if isTimerRunning {
                        Text(startTime ?? Date(), style: .timer)
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        
                        Button(action: stopTimer) {
                            Text("Wake Up")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(15)
                        }
                    } else {
                        Button(action: startTimer) {
                            Text("Good Night")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding()
                
                // History Section
                List {
                    Section(header: Text("Recent Sleep")) {
                        ForEach(networkManager.sleepLogs) { log in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(log.startTime, style: .date)
                                    Spacer()
                                    if let rating = log.qualityRating {
                                        HStack(spacing: 2) {
                                            ForEach(0..<rating, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(log.startTime, style: .time)
                                    Text("→")
                                    if let endTime = log.endTime {
                                        Text(endTime, style: .time)
                                        Spacer()
                                        Text(formatDuration(minutes: log.durationMinutes ?? 0))
                                            .fontWeight(.bold)
                                    } else {
                                        Text("Sleeping...")
                                            .foregroundColor(.blue)
                                            .italic()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sleep Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Manual Entry") { showingManualEntry = true }
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                NavigationView {
                    Form {
                        Section(header: Text("Time")) {
                            DatePicker("Start Time", selection: $manualStart)
                            DatePicker("End Time", selection: $manualEnd)
                        }
                        
                        Section(header: Text("Quality")) {
                            Picker("Rating", selection: $qualityRating) {
                                ForEach(1...5, id: \.self) { rating in
                                    Text("\(rating) Stars").tag(rating)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section(header: Text("Notes")) {
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .autocapitalization(.sentences)
                        }
                    }
                    .navigationTitle("Log Sleep")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingManualEntry = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveManualEntry()
                                showingManualEntry = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let child = networkManager.selectedChild {
                networkManager.fetchSleepLogs(childId: child.id)
            }
        }
    }
    
    func startTimer() {
        startTime = Date()
        isTimerRunning = true
        if let child = networkManager.selectedChild {
            networkManager.createSleepLog(childId: child.id, startTime: startTime!)
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        if let currentLog = networkManager.activeSleepLog {
            networkManager.updateSleepLog(logId: currentLog.id, endTime: Date(), rating: 3, notes: "")
        }
        startTime = nil
    }
    
    func saveManualEntry() {
        if let child = networkManager.selectedChild {
            networkManager.createManualSleepLog(childId: child.id, start: manualStart, end: manualEnd, rating: qualityRating, notes: notes)
        }
    }
    
    func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

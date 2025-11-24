import SwiftUI

struct HydrationLogView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var showingAddLog = false
    @State private var selectedAmount = 250
    @State private var selectedType = "Water"
    
    let fluidTypes = ["Water", "Milk", "Juice", "Formula"]
    let quickAmounts = [100, 250, 500]
    
    var body: some View {
        NavigationView {
            VStack {
                // Daily Total
                VStack {
                    Text("Today's Total")
                        .font(.headline)
                    Text("\(networkManager.dailyHydrationTotal) ml")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding()
                
                // Quick Add
                HStack(spacing: 20) {
                    ForEach(quickAmounts, id: \.self) { amount in
                        Button(action: { quickAdd(amount: amount) }) {
                            VStack {
                                Image(systemName: "drop.fill")
                                    .font(.title)
                                Text("\(amount)ml")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                }
                .padding(.bottom)
                
                // History
                List {
                    Section(header: Text("Recent Logs")) {
                        ForEach(networkManager.hydrationLogs) { log in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(log.fluidType)
                                        .font(.headline)
                                    Text(log.createdAt, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(log.amountMl) ml")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hydration")
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
                        Section(header: Text("Fluid Type")) {
                            Picker("Type", selection: $selectedType) {
                                ForEach(fluidTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section(header: Text("Amount (ml)")) {
                            Stepper(value: $selectedAmount, in: 10...1000, step: 10) {
                                Text("\(selectedAmount) ml")
                            }
                        }
                    }
                    .navigationTitle("Add Drink")
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
                networkManager.fetchHydrationLogs(childId: child.id)
            }
        }
    }
    
    func quickAdd(amount: Int) {
        if let child = networkManager.selectedChild {
            networkManager.createHydrationLog(childId: child.id, amount: amount, type: "Water", notes: "")
        }
    }
    
    func addLog() {
        if let child = networkManager.selectedChild {
            networkManager.createHydrationLog(childId: child.id, amount: selectedAmount, type: selectedType, notes: "")
        }
    }
}

import SwiftUI

struct ChildManagementView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var showingAddChild = false
    @State private var newChildName = ""
    @State private var newChildBirthdate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(networkManager.children) { child in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                            Text("Born: \(child.birthdate ?? "Unknown")") // Assuming birthdate is a string for now
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if networkManager.selectedChild?.id == child.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        networkManager.selectedChild = child
                    }
                }
                .onDelete(perform: deleteChild)
            }
            .navigationTitle("Manage Children")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddChild = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                NavigationView {
                    Form {
                        TextField("Name", text: $newChildName)
                        DatePicker("Birthdate", selection: $newChildBirthdate, displayedComponents: .date)
                    }
                    .navigationTitle("Add Child")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddChild = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                addChild()
                                showingAddChild = false
                            }
                            .disabled(newChildName.isEmpty)
                        }
                    }
                }
            }
        }
        .onAppear {
            networkManager.fetchChildren()
        }
    }
    
    func addChild() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: newChildBirthdate)
        
        networkManager.createChild(name: newChildName, birthdate: dateString)
        newChildName = ""
        newChildBirthdate = Date()
    }
    
    func deleteChild(at offsets: IndexSet) {
        offsets.forEach { index in
            let child = networkManager.children[index]
            networkManager.deleteChild(childId: child.id)
        }
    }
}

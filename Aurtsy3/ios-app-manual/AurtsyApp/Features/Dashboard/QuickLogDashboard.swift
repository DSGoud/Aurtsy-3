//
//  QuickLogDashboard.swift
//  Aurtsy
//
//  Created by dgoud on 9/19/25.
//  Updated on 11/23/25.
//

import SwiftUI

struct QuickLogDashboard: View {
    @EnvironmentObject var networkManager: NetworkManager
    let onOpenMealEntry: () -> Void
    
    @State private var showVoiceLog = false
    @State private var showingAddMenu = false
    @State private var showingSleepLog = false
    @State private var showingActivityLog = false
    @State private var showingBehaviorLog = false
    @State private var showingHydrationLog = false
    @State private var showingLocationCheck = false
    
    private let quickActions = [
        QuickAction(icon: "fork.knife", label: "Meal Log", description: "Food & nutrition", color: .orange, action: "meal"),
        QuickAction(icon: "bed.double.fill", label: "Sleep Log", description: "Rest & recovery", color: .blue, action: "sleep"),
        QuickAction(icon: "figure.walk", label: "Activity Log", description: "Exercise & movement", color: .green, action: "activity"),
        QuickAction(icon: "brain.head.profile", label: "Behavior Log", description: "Mood & incidents", color: .purple, action: "behavior"),
        QuickAction(icon: "drop.fill", label: "Hydration Log", description: "Water & fluids", color: .cyan, action: "hydration"),
        QuickAction(icon: "location.fill", label: "Location Check", description: "Current location", color: .red, action: "location")
    ]
    
    var body: some View {
        // ❌ No GeometryReader here – it can cause edge overlap on DI devices
        ScrollView {
            VStack(spacing: 0) {
                // Header sits below the Dynamic Island (see .safeAreaPadding(.top) below)
                // Header sits below the Dynamic Island (see .safeAreaPadding(.top) below)
                ModernHeader()
                
                // Main content
                VStack(spacing: 24) {
                    // Context Card (Magic Handoff)
                    if let summary = networkManager.handoffSummary {
                        ContextCardView(summary: summary)
                            .padding(.bottom, 8)
                    } else {
                        // Fallback / Loading state
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Gathering context...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    }
                        
                    // Quick Actions Grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                        spacing: 12
                    ) {
                        ForEach(quickActions, id: \.label) { action in
                            QuickActionCard(action: action) {
                                switch action.action {
                                case "meal": onOpenMealEntry()
                                case "sleep": showingSleepLog = true
                                case "activity": showingActivityLog = true
                                case "behavior": showingBehaviorLog = true
                                case "hydration": showingHydrationLog = true
                                case "location": showingLocationCheck = true
                                default: break
                                }
                            }
                        }
                    }
                    
                    // Recent Activity
                    ActivityFeedView()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                // A little breathing room above the custom tab bar
                .padding(.bottom, 16)
            }
        }
        .scrollIndicators(.hidden)
        .background(
            LinearGradient(
                colors: [Color(UIColor.systemBackground),
                         Color(UIColor.secondarySystemBackground).opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // background can go edge-to-edge
        )
        .background(Color(UIColor.systemGroupedBackground)) // New background
        .overlay(
            // Floating Action Button for Voice Log
            Button(action: {
                showVoiceLog = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20),
            alignment: .bottomTrailing
        )
        .padding(.top)
        .onAppear {
            // Fetch all data when view appears
            if let child = networkManager.selectedChild {
                networkManager.fetchHandoffSummary(childId: child.id)
                Task {
                    try? await networkManager.fetchMeals(childId: child.id)
                }
                networkManager.fetchSleepLogs(childId: child.id)
                networkManager.fetchActivityLogs(childId: child.id)
                networkManager.fetchBehaviorLogs(childId: child.id)
                networkManager.fetchHydrationLogs(childId: child.id)
                networkManager.fetchActivityFeed(childId: child.id) // New fetch
            }
        }
        .sheet(isPresented: $showingSleepLog) { SleepLogView() }
        .sheet(isPresented: $showingBehaviorLog) { BehaviorLogView() }
        .sheet(isPresented: $showingHydrationLog) { HydrationLogView() }
        .sheet(isPresented: $showingLocationCheck) { LocationCheckView() }
        .sheet(isPresented: $showingActivityLog) { ActivityLogView() }
        .sheet(isPresented: $showVoiceLog) { // New sheet for voice log
            VoiceLogView()
        }
    }
}

// MARK: - Components used within QuickLogDashboard

struct QuickActionCard: View {
    let action: QuickAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.system(size: 24))
                    .foregroundColor(action.color)
                
                VStack(spacing: 2) {
                    Text(action.label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [action.color.opacity(0.05), action.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(action.color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FloatingVoiceButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "mic.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(LinearGradient(colors: [.primary, .primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FloatingPhotoButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "camera.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Reusable bits

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct QuickAction {
    let icon: String
    let label: String
    let description: String
    let color: Color
    let action: String
}
import SwiftUI

struct ContextCardView: View {
    let summary: NetworkManager.HandoffSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("Magic Handoff")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                // Alert Level Badge
                Text(summary.alertLevel)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(alertColor.opacity(0.2))
                    .foregroundColor(alertColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(alertColor, lineWidth: 1)
                    )
            }
            
            // Summary Points
            VStack(alignment: .leading, spacing: 8) {
                ForEach(summary.summary, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(point)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Recommendations (if any)
            if !summary.recommendations.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SUGGESTIONS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                    
                    ForEach(summary.recommendations, id: \.self) { rec in
                        Text("• \(rec)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: Color(hex: "4F46E5").opacity(0.3), radius: 12, x: 0, y: 8)
    }
    
    var alertColor: Color {
        switch summary.alertLevel {
        case "HIGH": return .red
        case "MEDIUM": return .orange
        default: return .green
        }
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

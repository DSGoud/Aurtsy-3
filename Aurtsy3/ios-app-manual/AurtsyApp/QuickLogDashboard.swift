//
//  QuickLogDashboard.swift
//  Aurtsy
//
//  Created by dgoud on 9/19/25.
//  Updated on 11/23/25.
//

import SwiftUI

struct QuickLogDashboard: View {
    let onOpenMealEntry: () -> Void
    
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
                ModernHeader()
                
                // Main content
                VStack(spacing: 24) {
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quick Actions")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Log care activities and track progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
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
        // Make sure content starts below the Dynamic Island / status bar
        .padding(.top)
        // Floating mic anchored with safe-area awareness (no hard 100pt magic number)
        .overlay(alignment: .bottomTrailing) {
            FloatingVoiceButton()
                .padding(.trailing, 20)
                .padding(.bottom, 72) // sits nicely above your custom tab bar
        }
        .sheet(isPresented: $showingSleepLog) { SleepLogView() }
        .sheet(isPresented: $showingBehaviorLog) { BehaviorLogView() }
        .sheet(isPresented: $showingHydrationLog) { HydrationLogView() }
        .sheet(isPresented: $showingLocationCheck) { LocationCheckView() }
        .sheet(isPresented: $showingActivityLog) { ActivityLogView() }
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

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var network: NetworkManager
    let childId: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if network.isLoadingAnalytics {
                        ProgressView("Loading insights...")
                            .padding()
                    } else if let summary = network.weeklySummary {
                        // Regulation Battery
                        RegulationBatteryCard(battery: summary.regulationBattery)
                        
                        // Open Loops
                        if !summary.openLoops.isEmpty {
                            OpenLoopsCard(loops: summary.openLoops)
                        }
                        
                        // ABC Analysis
                        if summary.abcAnalysis.totalIncidents > 0 {
                            ABCAnalysisCard(analysis: summary.abcAnalysis)
                        }
                        
                        // Insights
                        if !summary.insights.isEmpty {
                            InsightsCard(insights: summary.insights)
                        }
                        
                        // Weekly Stats
                        WeeklyStatsCard(summary: summary)
                    } else {
                        ContentUnavailableView(
                            "No Analytics Available",
                            systemImage: "chart.xyaxis.line",
                            description: Text("Start logging meals and behaviors to see insights.")
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
            .refreshable {
                network.fetchWeeklySummary(childId: childId)
            }
            .onAppear {
                network.fetchWeeklySummary(childId: childId)
            }
        }
    }
}

// MARK: - Regulation Battery Card

struct RegulationBatteryCard: View {
    let battery: RegulationBattery
    
    var batteryColor: Color {
        switch battery.level {
        case 80...100: return .green
        case 50...79: return .yellow
        case 20...49: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.batteryblock.fill")
                    .font(.title2)
                    .foregroundColor(batteryColor)
                Text("Regulation Battery")
                    .font(.headline)
                Spacer()
                Text("\(battery.level)%")
                    .font(.title2.bold())
                    .foregroundColor(batteryColor)
            }
            
            // Battery bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(batteryColor)
                        .frame(width: geometry.size.width * CGFloat(battery.level) / 100)
                }
            }
            .frame(height: 20)
            
            Text(battery.status)
                .font(.subheadline.bold())
                .foregroundColor(batteryColor)
            
            if !battery.inputs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Charging:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    ForEach(battery.inputs, id: \.self) { input in
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                            Text(input)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !battery.drains.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Draining:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    ForEach(battery.drains, id: \.self) { drain in
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.red)
                            Text(drain)
                                .font(.caption)
                        }
                    }
                }
            }
            
            Text(battery.recommendation)
                .font(.callout)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(batteryColor.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - Open Loops Card

struct OpenLoopsCard: View {
    let loops: [OpenLoop]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.orange)
                Text("Open Loops (\(loops.count))")
                    .font(.headline)
            }
            
            ForEach(loops) { loop in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loop.requestObject)
                            .font(.subheadline.bold())
                        Text("\(loop.timeElapsedMinutes) minutes ago • \(loop.status)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(loop.riskLevel)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(loop.riskLevel == "High" ? Color.red.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(loop.riskLevel == "High" ? .red : .orange)
                        .cornerRadius(4)
                }
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - ABC Analysis Card

struct ABCAnalysisCard: View {
    let analysis: ABCAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Behavior Patterns")
                .font(.headline)
            
            if !analysis.topTriggers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Triggers")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    
                    ForEach(analysis.topTriggers, id: \.label) { stat in
                        HStack {
                            Text(stat.label)
                                .font(.caption)
                            Spacer()
                            Text("\(stat.count)x")
                                .font(.caption.bold())
                            Text("(\(String(format: "%.1f", stat.percentage))%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: geometry.size.width * CGFloat(stat.percentage / 100), height: 6)
                        }
                        .frame(height: 6)
                    }
                }
            }
            
            if !analysis.effectiveInterventions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What Works")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    
                    ForEach(analysis.effectiveInterventions, id: \.label) { stat in
                        HStack {
                            Text(stat.label)
                                .font(.caption)
                            Spacer()
                            Text("\(stat.count)x")
                                .font(.caption.bold())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - Insights Card

struct InsightsCard: View {
    let insights: [Insight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discoveries")
                .font(.headline)
            
            ForEach(insights, id: \.title) { insight in
                VStack(alignment: .leading, spacing: 6) {
                    Label(insight.title, systemImage: "lightbulb.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    
                    Text(insight.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let tip = insight.actionableTip {
                        Text("💡 \(tip)")
                            .font(.caption)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - Weekly Stats Card

struct WeeklyStatsCard: View {
    let summary: WeeklySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatBox(label: "Meals", value: "\(summary.totalMeals)", color: .orange)
                StatBox(label: "Sleep", value: String(format: "%.1fh", summary.totalSleepHours), color: .blue)
                StatBox(label: "Quality", value: String(format: "%.1f", summary.avgSleepQuality), color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

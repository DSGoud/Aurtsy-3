import Foundation
import SwiftUI

enum Role: String, Codable {
    case admin = "ADMIN"
    case parent = "PARENT"
    case teacher = "TEACHER"
    case caregiver = "CAREGIVER"
    case aide = "AIDE"
    case child = "CHILD"
    case schoolAdmin = "SCHOOL_ADMIN"
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let role: Role
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, email, role
        case isActive = "is_active"
    }
}

struct Child: Codable, Identifiable {
    let id: String
    let name: String
    let birthdate: String?
}

struct Meal: Codable, Identifiable {
    let id: Int
    let childId: String
    let userId: String
    let mealType: String
    let photoUrl: String?
    let notes: String?
    let analysisStatus: String
    let createdAt: Date
}

struct SleepLog: Codable, Identifiable {
    let id: Int
    let childId: String
    let startTime: Date
    let endTime: Date?
    let durationMinutes: Int?
    let qualityRating: Int?
    let notes: String?
    let createdAt: Date
}

struct Activity: Codable, Identifiable {
    let id: Int
    let childId: String
    let activityType: String
    let durationMinutes: Int
    let details: String?
    let createdAt: Date
}

struct HydrationLog: Codable, Identifiable {
    let id: Int
    let childId: String
    let fluidType: String
    let amountMl: Int
    let notes: String?
    let createdAt: Date
}

struct LocationCheck: Codable, Identifiable {
    let id: Int
    let childId: String
    let latitude: String
    let longitude: String
    let locationName: String
    let createdAt: Date
}

struct BehaviorLog: Codable, Identifiable {
    let id: Int
    let childId: String
    let behaviorType: String
    let moodRating: Int?
    let incidentDescription: String?
    let severity: Int?
    let createdAt: Date
}

struct DailyHydrationTotal: Codable {
    let childId: String
    let date: String
    let totalMl: Int
}

enum FeedItemType: String, Codable {
    case meal, behavior, sleep, activity, hydration
}

struct FeedItem: Identifiable, Equatable {
    let id: String
    let type: FeedItemType
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var color: Color {
        switch self.type {
        case .meal: return .orange
        case .behavior: return .purple
        case .sleep: return .blue
        case .activity: return .green
        case .hydration: return .cyan
        }
    }
}

struct HandoffSummary: Codable {
    let summary: [String]
    let alertLevel: String
    let recommendations: [String]
}

struct VoiceProcessResponse: Codable {
    let success: Bool
    let processedTypes: [String]
    let message: String
}

struct ActivityFeed: Codable {
    let childId: String
    let sleepLogs: [SleepLog]
    let behaviorLogs: [BehaviorLog]
    let hydrationLogs: [HydrationLog]
    let locationChecks: [LocationCheck]
    let activities: [Activity]
    
    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case sleepLogs = "sleep_logs"
        case behaviorLogs = "behavior_logs"
        case hydrationLogs = "hydration_logs"
        case locationChecks = "location_checks"
        case activities
    }
}

// MARK: - Analytics Models

struct RegulationBattery: Codable {
    let level: Int // 0-100
    let status: String // High, Moderate, Low, Critical
    let inputs: [String]
    let drains: [String]
    let recommendation: String
}

struct OpenLoop: Codable, Identifiable {
    let id: Int
    let requestObject: String
    let status: String
    let timestamp: Date
    let timeElapsedMinutes: Int
    let riskLevel: String
}

struct ABCStat: Codable {
    let label: String
    let count: Int
    let percentage: Double
}

struct ABCAnalysis: Codable {
    let topTriggers: [ABCStat]
    let effectiveInterventions: [ABCStat]
    let totalIncidents: Int
}

struct Insight: Codable {
    let type: String // correlation, pattern, alert
    let title: String
    let description: String
    let confidence: String
    let actionableTip: String?
}

struct WeeklySummary: Codable {
    let weekStart: Date
    let weekEnd: Date
    let totalMeals: Int
    let totalSleepHours: Double
    let avgSleepQuality: Double
    let totalIncidents: Int
    let regulationBattery: RegulationBattery
    let openLoops: [OpenLoop]
    let abcAnalysis: ABCAnalysis
    let insights: [Insight]
}

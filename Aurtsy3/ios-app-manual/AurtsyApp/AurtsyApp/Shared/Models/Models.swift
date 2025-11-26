import Foundation

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
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case durationMinutes = "duration_minutes"
        case qualityRating = "quality_rating"
        case notes
        case createdAt = "created_at"
    }
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

struct HydrationLog: Codable, Identifiable {
    let id: Int
    let childId: String
    let fluidType: String
    let amountMl: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case fluidType = "fluid_type"
        case amountMl = "amount_ml"
        case createdAt = "created_at"
    }
}

struct DailyHydrationTotal: Codable {
    let childId: String
    let date: String
    let totalMl: Int
    
    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case date
        case totalMl = "total_ml"
    }
}

struct LocationCheck: Codable, Identifiable {
    let id: Int
    let childId: String
    let latitude: String
    let longitude: String
    let locationName: String?
    let notes: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case latitude, longitude
        case locationName = "location_name"
        case notes
        case createdAt = "created_at"
    }
}

struct Activity: Codable, Identifiable {
    let id: Int
    let childId: String
    let activityType: String
    let details: [String: AnyCodable]?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case activityType = "activity_type"
        case details
        case createdAt = "created_at"
    }
}

// Helper for AnyCodable since Swift Codable doesn't handle [String: Any] directly
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) { value = x }
        else if let x = try? container.decode(Double.self) { value = x }
        else if let x = try? container.decode(String.self) { value = x }
        else if let x = try? container.decode(Bool.self) { value = x }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded") }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let x = value as? Int { try container.encode(x) }
        else if let x = value as? Double { try container.encode(x) }
        else if let x = value as? String { try container.encode(x) }
        else if let x = value as? Bool { try container.encode(x) }
        else { throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable value cannot be encoded")) }
    }
}

// Feed Models
enum FeedItemType {
    case meal
    case sleep, behavior, hydration, location, activity
}

struct FeedItem: Identifiable {
    let id: String
    let type: FeedItemType
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
    let color: Color
    
    var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

import SwiftUI // For Color

struct RawActivityFeed: Codable {
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


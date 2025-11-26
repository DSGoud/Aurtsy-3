# Aurtsy Technical Overview

## Project Architecture

**Aurtsy** is a special needs caregiving app with a **FastAPI backend** and **SwiftUI iOS frontend**, designed to help parents and caregivers track and manage care for children with autism.

### Tech Stack

#### Backend
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **AI/LLM**: Ollama (local LLM for voice log processing)
- **Task Queue**: Celery + Redis
- **Storage**: MinIO (S3-compatible object storage)
- **Deployment**: Docker Compose

#### Frontend (iOS)
- **Framework**: SwiftUI
- **Language**: Swift
- **Architecture**: MVVM with ObservableObject
- **Networking**: URLSession (async/await)
- **Charts**: Swift Charts

---

## System Components

### 1. Backend API (`/backend`)

The backend is organized into **domain-driven modules**:

```
backend/app/domains/
├── ai/          # Voice log processing with LLM
├── users/       # Authentication & user management
├── children/    # Child profiles
├── meals/       # Meal tracking
├── behavior/    # Behavior logs (ABC analysis)
├── sleep/       # Sleep tracking
├── activities/  # Activity logs
├── hydration/   # Fluid intake
└── alerts/      # Notifications
```

#### Key Endpoints

**Children & Resources**
- `GET /children/` - List all children
- `GET /children/{child_id}/meals/` - Get child's meals
- `GET /children/{child_id}/behavior/` - Get child's behaviors
- `GET /children/{child_id}/sleep/` - Get sleep logs

**AI Processing**
- `POST /ai/process_log` - Process voice note with LLM
  - Classifies input (Meal, Behavior, Sleep, etc.)
  - Extracts structured data
  - Saves to appropriate tables

**Meals**
- `POST /meals/` - Create meal entry
- `GET /meals/children/{child_id}/meals/` - Fetch meals

---

### 2. iOS App (`/ios-app-manual/AurtsyApp`)

#### Architecture Pattern: MVVM

**Models** (`Shared/Models/Models.swift`)
- Data structures: `User`, `Child`, `Meal`, `BehaviorLog`, `SleepLog`, etc.
- Codable for JSON parsing
- Uses `.convertFromSnakeCase` for backend compatibility

**ViewModels** (`Core/NetworkManager.swift`)
- `@Published` properties for reactive UI updates
- Handles all API calls
- Manages app state (currentUser, selectedChild, meals, behaviorLogs, etc.)

**Views** (`Features/`)
- SwiftUI views organized by feature
- `HistoryView`, `VoiceLogView`, `QuickLogDashboard`, etc.

#### Key Features

**Voice Log Processing**
1. User records voice note via microphone FAB
2. Text sent to `/ai/process_log` endpoint
3. Backend LLM extracts:
   - **Meals**: Food items, meal type
   - **Behaviors**: ABC analysis (Antecedent → Behavior → Consequence)
4. Data saved to database
5. iOS app refreshes to show new entries

**History View**
- Aggregates all log types into unified feed
- Time-range filtering (4h, 12h, 24h, 7d)
- Charts for mood and sleep trends
- Pull-to-refresh for manual updates

---

## Data Flow: Voice Log Example

```
┌─────────────┐
│ iOS App     │
│ Voice Input │
└──────┬──────┘
       │ "John had a meltdown, ate popcorn, felt better"
       ↓
┌──────────────────────────┐
│ Backend: /ai/process_log │
│ (Ollama LLM)             │
└──────┬───────────────────┘
       │ Extracts:
       │ - BEHAVIOR: meltdown (ABC format)
       │ - MEAL: popcorn (SNACK)
       ↓
┌─────────────────┐
│ PostgreSQL DB   │
│ ├─ behaviors    │
│ └─ meals        │
└─────────┬───────┘
          │
          ↓
┌─────────────────────────┐
│ iOS fetches:            │
│ GET /children/john_001/ │
│   ├─ /meals/            │
│   └─ /behavior/         │
└─────────────────────────┘
          │
          ↓
┌─────────────────┐
│ History View    │
│ Shows both:     │
│ - Popcorn meal  │
│ - Meltdown log  │
└─────────────────┘
```

---

## Database Schema (Key Tables)

### `meals`
```sql
id, child_id, user_id, meal_type, notes, photo_url, 
analysis_status, analysis_json, created_at
```

### `behavior_logs`
```sql
id, child_id, behavior_type, mood_rating, 
incident_description (ABC format), severity, created_at
```

### `sleep_logs`
```sql
id, child_id, start_time, end_time, 
duration_minutes, quality_rating, created_at
```

---

## AI/LLM Integration

### Voice Log Processing

**LLM Provider**: Ollama (running locally in Docker)  
**Default Model**: `qwen2.5-coder:14b-instruct`  
**Configuration**: Set via `OLLAMA_MODEL` environment variable  
**Server**: Remote at `http://100.80.85.59:11434`

**Prompt Engineering**: Uses structured prompt with:
- **ABC Model** for behaviors (Antecedent → Behavior → Consequence)
- Multi-event extraction (one voice note can contain meal + behavior)
- Temporal relationship understanding

**Example Input**:
> "John was having a meltdown earlier today. We offered him a snack. He ate popcorn and felt better."

**LLM Output** (JSON):
```json
{
  "classifications": ["BEHAVIOR", "MEAL"],
  "entries": [
    {
      "type": "BEHAVIOR",
      "data": {
        "behavior_type": "meltdown",
        "mood_rating": 2,
        "incident_description": "Antecedent: Unknown/hunger, Behavior: Meltdown, Consequence: Resolved with popcorn snack"
      }
    },
    {
      "type": "MEAL",
      "data": {
        "meal_type": "SNACK",
        "notes": "Popcorn"
      }
    }
  ]
}
```

---

## iOS Technical Details

### JSON Decoding Strategy

**Issue**: Backend returns `snake_case` (e.g., `child_id`), Swift uses `camelCase` (e.g., `childId`)

**Solution**: 
```swift
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

**Critical**: Do NOT use custom `CodingKeys` when using `.convertFromSnakeCase` - they conflict!

### Date Handling

**Issue**: Backend returns ISO8601 with fractional seconds:
```
2025-11-26T04:27:11.024554+00:00
```

**Solution**: Custom date decoder
```swift
let dateFormatter = ISO8601DateFormatter()
dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
decoder.dateDecodingStrategy = .custom { ... }
```

### State Management

Uses `@Published` properties in `NetworkManager` (ObservableObject):
- Changes automatically trigger UI updates
- Views subscribe using `@EnvironmentObject` or `@ObservedObject`

---

## Deployment

### Backend Deployment

```bash
./deploy_to_epyc.sh
```

**What it does**:
1. Rsyncs code to remote server (100.79.130.75)
2. Rebuilds Docker images
3. Restarts containers (backend, worker, db, redis, minio)

### iOS Development

**Build**: `Cmd+B`  
**Run**: `Cmd+R`  
**Clean**: `Cmd+Shift+K` (important when changing models!)

---

## Common Issues & Solutions

### 1. **Data not showing in History**

**Symptoms**: Voice logs saved but not visible

**Causes**:
- Wrong child selected (data under John but viewing Test Child)
- iOS models have CodingKeys conflict
- Date format mismatch

**Fix**: 
- Switch to correct child
- Remove CodingKeys from models using `.convertFromSnakeCase`
- Use custom date decoder

### 2. **Behavior logs failing to decode**

**Error**: `keyNotFound: "child_id"`

**Cause**: CodingKeys enum + `.convertFromSnakeCase` together

**Fix**: Remove CodingKeys enum, let decoder handle conversion

### 3. **Pull-to-refresh not working**

**Cause**: Stale app build

**Fix**: Clean build folder (Cmd+Shift+K), rebuild, run

---

## Future Enhancements

### Planned Features
- Photo analysis for meal logging
- Medication tracking
- School/therapy session notes
- Multi-caregiver collaboration
- Pattern recognition & insights
- Export reports for medical professionals

### Technical Improvements
- Push notifications (APNs)
- Offline mode with sync
- GraphQL API
- React Native for Android
- AI-powered insights dashboard

---

## Development Workflow

1. **Backend changes**: Edit domain code → `./deploy_to_epyc.sh`
2. **iOS changes**: Edit SwiftUI code → Cmd+B → Cmd+R
3. **Test**: Use curl for backend, Xcode simulator for iOS
4. **Debug**: Check Xcode console logs (🍽️, 📊, ❌ emojis)
5. **Commit**: `git add -A && git commit -m "message"`

---

## Key Files Reference

**Backend**
- [`backend/app/domains/ai/service.py`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/backend/app/domains/ai/service.py) - LLM processing logic
- [`backend/app/domains/children/router.py`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/backend/app/domains/children/router.py) - Child resource endpoints
- [`backend/app/main.py`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/backend/app/main.py) - FastAPI app setup

**iOS**
- [`ios-app-manual/AurtsyApp/AurtsyApp/Core/NetworkManager.swift`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-manual/AurtsyApp/AurtsyApp/Core/NetworkManager.swift) - API client
- [`ios-app-manual/AurtsyApp/AurtsyApp/Shared/Models/Models.swift`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-manual/AurtsyApp/AurtsyApp/Shared/Models/Models.swift) - Data models
- [`ios-app-manual/AurtsyApp/AurtsyApp/Features/Dashboard/HistoryView.swift`](file:///Users/dhrugoud/Aurtsy_git/Aurtsy-3/Aurtsy3/ios-app-manual/AurtsyApp/AurtsyApp/Features/Dashboard/HistoryView.swift) - History UI

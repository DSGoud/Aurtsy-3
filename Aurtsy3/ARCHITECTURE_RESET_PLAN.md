# Architecture Reset & Build Fix Plan

**Date:** 2025-11-23  
**Status:** Ready to Execute  
**Goal:** Get iOS app building, then refactor into modular architecture

---

## Current State

- ✅ iOS app with working UI (not building due to Swift 6 concurrency errors)
- ✅ FastAPI backend running on `epycserver` (100.79.130.75:8090)
- ✅ PostgreSQL database operational
- ✅ Three powerful machines: M4 Mac Studio, EPYC server, RTX 4090 box
- ❌ Build fails due to Swift concurrency issues

---

## Machine Roles

### M4 Mac Studio (`gouds-mac-studio`)
- **Primary dev box**
- Xcode + iOS Simulator
- Local testing environment
- Git repository management

### EPYC Server (`epycserver` - 100.79.130.75)
- **Main backend stack**
- FastAPI modular monolith
- PostgreSQL database
- Redis (caching, message queue)
- MinIO (S3-compatible object storage)
- Docker/docker-compose deployment

### RTX 4090 Box (`pop-os`)
- **ML/AI inference service**
- PyTorch/TensorFlow models
- Image classification for meal photos
- Communicates with backend via HTTP
- Runs separately from main backend

### Synology NAS (`goudnas`)
- Backups and archives
- Optional: S3-compatible storage for photos

---

## Phase 1: Fix iOS Build (IMMEDIATE)

### 1.1 Safety & Cleanup ✅
- [x] Create git commit snapshot
- [x] Clean Xcode DerivedData
- [ ] Reset Swift Package caches

### 1.2 Remove Dangerous Flags
- [ ] Remove `-Xfrontend -disable-availability-checking` from Build Settings
- [ ] Set "Swift Concurrency Checking" to **Minimal** (not Strict)
- [ ] Set "Treat Warnings as Errors" to **No** for Debug/Release

### 1.3 Fix Top Errors Systematically
- [ ] Build and capture first error
- [ ] Apply fixes based on error type:
  - **Main actor isolation**: Add `@MainActor` to ViewModels/ObservableObjects
  - **Async in sync context**: Wrap in `Task { await ... }`
  - **Sendable complaints**: Use `@MainActor` or `@unchecked Sendable` carefully
- [ ] Repeat until build succeeds

### 1.4 Common Fixes to Apply

**NetworkManager:**
```swift
@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    // All @Published properties now safe
}
```

**Button actions with async:**
```swift
Button("Load") {
    Task {
        await viewModel.load()
    }
}
```

---

## Phase 2: Organize iOS Codebase

### 2.1 Current Structure
```
ios-app/
└── Sources/AurtsyApp/
    ├── *.swift (all files flat)
```

### 2.2 Target Structure
```
ios-app/
└── Sources/AurtsyApp/
    ├── Core/
    │   ├── Networking/
    │   │   ├── NetworkManager.swift
    │   │   └── APIClient.swift
    │   ├── Models/
    │   │   └── Models.swift
    │   └── Services/
    │       └── (shared services)
    ├── Features/
    │   ├── Dashboard/
    │   │   ├── QuickLogDashboard.swift
    │   │   └── ContentView.swift
    │   ├── Meals/
    │   │   └── MealEntryModal.swift
    │   ├── Activity/
    │   │   ├── ActivityLogView.swift
    │   │   └── ActivityFeedView.swift
    │   ├── Behavior/
    │   │   └── BehaviorLogView.swift
    │   ├── Sleep/
    │   │   └── SleepLogView.swift
    │   ├── Hydration/
    │   │   └── HydrationLogView.swift
    │   └── Location/
    │       └── LocationCheckView.swift
    └── Shared/
        ├── UI/
        │   ├── ModernHeader.swift
        │   └── PrimaryCapsule.swift
        └── (utilities)
```

### 2.3 Execution
- [ ] Create folder structure in Xcode
- [ ] Move files into appropriate groups
- [ ] Verify build still works
- [ ] Commit: "refactor: organize into feature modules"

---

## Phase 3: Backend Refactoring (Modular Monolith)

### 3.1 Current Structure
```
backend/
├── main.py (all routes)
├── models.py
├── schemas.py
├── crud.py
└── database.py
```

### 3.2 Target Structure
```
backend/
├── app/
│   ├── main.py (app creation, route registration)
│   ├── core/
│   │   ├── config.py
│   │   ├── db.py
│   │   └── events.py (event bus)
│   └── domains/
│       ├── users/
│       │   ├── models.py
│       │   ├── schemas.py
│       │   ├── service.py
│       │   └── router.py
│       ├── meals/
│       │   ├── models.py
│       │   ├── schemas.py
│       │   ├── service.py
│       │   └── router.py
│       ├── activities/
│       ├── behaviors/
│       ├── sleep/
│       ├── hydration/
│       ├── location/
│       └── alerts/
│           ├── models.py
│           ├── service.py
│           ├── handlers.py (event subscribers)
│           └── router.py
├── tests/
└── requirements.txt
```

### 3.3 Event-Driven Architecture

**Event Bus (`core/events.py`):**
```python
class EventBus:
    def subscribe(self, event_name: str, handler: Callable)
    async def publish(self, event_name: str, payload: Any)
```

**Example Flow:**
1. `POST /v1/meals` → `meals/service.py` saves meal
2. Publishes `MealLogged` event
3. `alerts/handlers.py` subscribes to `MealLogged`
4. Checks rules, sends notification if needed

### 3.4 Execution Steps
- [ ] Create `app/core/events.py` with simple event bus
- [ ] Create domain folders
- [ ] Move existing code into `domains/meals/`
- [ ] Add event publish to meal logging
- [ ] Create `alerts/handlers.py` to subscribe
- [ ] Test: log meal → alert fires
- [ ] Repeat for other domains

---

## Phase 4: Infrastructure (Docker Compose)

### 4.1 Create `infra/docker-compose.dev.yml`
```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: aurtsy
      POSTGRES_USER: aurtsy
      POSTGRES_PASSWORD: aurtsy
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: aurtsy
      MINIO_ROOT_PASSWORD: aurtsy-secret
    volumes:
      - minio_data:/data

  backend:
    build: ../backend
    depends_on: [db, redis, minio]
    environment:
      DATABASE_URL: postgresql+asyncpg://aurtsy:aurtsy@db:5432/aurtsy
      REDIS_URL: redis://redis:6379/0
      OBJECT_STORAGE_ENDPOINT: http://minio:9000
    ports:
      - "8090:8000"

volumes:
  postgres_data:
  minio_data:
```

### 4.2 Deployment
- [ ] Create `infra/` directory
- [ ] Add `docker-compose.dev.yml`
- [ ] Deploy to `epycserver`:
  ```bash
  ssh agoud@epycserver
  cd /path/to/Aurtsy3/infra
  docker compose -f docker-compose.dev.yml up --build
  ```

---

## Phase 5: ML Service Integration (Later)

### 5.1 ML Service on RTX 4090 Box
```
ml/
└── services/
    └── meal_vision/
        ├── main.py (FastAPI server)
        ├── model.py (PyTorch model)
        └── requirements.txt
```

### 5.2 Integration
- Backend calls `http://pop-os:PORT/infer` for image classification
- Triggered by `MealLogged` event handler
- Async processing, doesn't block API response

---

## Phase 6: Offline-First iOS (Future)

### 6.1 Local Storage
- Use SwiftData for local meal/activity storage
- Save locally first, sync in background

### 6.2 Sync Service
```swift
protocol SyncService {
    func syncPendingData() async throws
}
```

- Background tasks (BGAppRefreshTask)
- Upload to backend when connectivity available
- Mark as synced in local DB

---

## Success Criteria

### Phase 1 (Immediate)
- ✅ iOS app builds without errors
- ✅ Can run in simulator
- ✅ Basic flows work (login, view dashboard)

### Phase 2 (This Week)
- ✅ Code organized into feature modules
- ✅ Clean folder structure
- ✅ No regressions

### Phase 3 (Next 2 Weeks)
- ✅ Backend split into domain modules
- ✅ Event bus operational
- ✅ One complete event flow working (MealLogged → Alert)

### Phase 4 (Next 2 Weeks)
- ✅ Docker Compose running on epycserver
- ✅ iOS app connects to new backend
- ✅ End-to-end testing successful

---

## Rollback Plan

If anything breaks:
```bash
git reset --hard HEAD~1  # Undo last commit
git clean -fd            # Remove untracked files
```

Or restore to snapshot:
```bash
git checkout 46d9087  # The "WIP: snapshot" commit
```

---

## Next Immediate Actions

1. **Fix iOS Build** (30-60 min)
   - Reset package caches
   - Remove unsafe flags
   - Fix top 3 errors
   - Iterate until build succeeds

2. **Organize iOS Code** (30 min)
   - Create folder structure
   - Move files
   - Verify build

3. **Backend Event Bus** (1-2 hours)
   - Create `events.py`
   - Refactor meal logging
   - Add alert handler

4. **Deploy to Docker** (1 hour)
   - Create docker-compose
   - Deploy to epycserver
   - Test from iOS

---

## Notes

- **Don't rewrite everything** - refactor incrementally
- **Keep existing UI** - it works, just fix the plumbing
- **Test after each phase** - don't accumulate changes
- **Document as you go** - update this plan with learnings

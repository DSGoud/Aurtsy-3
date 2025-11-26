# Aurtsy Project Folder Structure

## Why So Many Nested Folders?

The nested structure you see is typical for iOS Xcode projects. Here's what each level means:

```
Aurtsy3/                              # Root project directory
├── backend/                          # FastAPI backend (Python)
│   └── app/
│       ├── core/                     # Core utilities (database, LLM client)
│       └── domains/                  # Business logic by domain
│           ├── ai/                   # Voice log AI processing
│           ├── meals/                # Meal tracking
│           ├── behavior/             # Behavior logs
│           └── ...
│
├── infra/                            # Docker & deployment configs
│   └── docker-compose.dev.yml
│
└── ios-app-manual/                   # iOS app folder
    └── AurtsyApp/                    # ← Xcode PROJECT folder (contains .xcodeproj)
        ├── AurtsyApp.xcodeproj/      # Xcode project file
        └── AurtsyApp/                # ← Actual APP CODE folder
            ├── Core/                 # App entry point, NetworkManager
            ├── Features/             # UI screens by feature
            │   ├── Dashboard/        # HistoryView, VoiceLogView
            │   ├── Meal/             # Meal entry screens
            │   └── Behavior/         # Behavior logging
            └── Shared/               # Shared code
                ├── Models/           # Data models (Meal, BehaviorLog, etc.)
                └── UI/               # Reusable UI components
```

## Why the Double "AurtsyApp" Nesting?

This is **standard Xcode convention**:

1. **Outer `AurtsyApp/`**: Contains the Xcode project file (`.xcodeproj`)
2. **Inner `AurtsyApp/`**: Contains the actual Swift source code

**Why?** Xcode projects can have multiple targets (iOS app, watchOS app, tests, etc.), so the outer folder groups everything related to the project, while inner folders separate each target's code.

## Simplified View - What You Actually Work With

**For Backend Development:**
- Work in: `backend/app/domains/`
- Deploy: `./deploy_to_epyc.sh`

**For iOS Development:**
- Open: `ios-app-manual/AurtsyApp/AurtsyApp.xcodeproj` in Xcode
- Code in: `ios-app-manual/AurtsyApp/AurtsyApp/` (shows as "AurtsyApp" in Xcode sidebar)

## Key Files Quick Reference

| What | Path |
|------|------|
| **Open in Xcode** | `ios-app-manual/AurtsyApp/AurtsyApp.xcodeproj` |
| **iOS Models** | `ios-app-manual/AurtsyApp/AurtsyApp/Shared/Models/Models.swift` |
| **Network Layer** | `ios-app-manual/AurtsyApp/AurtsyApp/Core/NetworkManager.swift` |
| **History View** | `ios-app-manual/AurtsyApp/AurtsyApp/Features/Dashboard/HistoryView.swift` |
| **AI Service** | `backend/app/domains/ai/service.py` |
| **Backend Main** | `backend/app/main.py` |
| **Deploy Script** | `deploy_to_epyc.sh` |

## Clean This Up?

If you want a flatter structure, you could:
1. Rename `ios-app-manual/AurtsyApp/AurtsyApp/` → `ios-app-manual/AurtsyApp/Sources/`
2. But this is **non-standard** and might confuse other iOS developers

**Recommendation**: Keep it as-is - it's the standard iOS project structure that any iOS developer will recognize immediately.

## TL;DR

- **Backend**: `backend/app/domains/` - clean and organized ✓
- **iOS**: Nested because of Xcode conventions - normal ✓
- **In Xcode**: It looks clean! The nesting is just on disk.

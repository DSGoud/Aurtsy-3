# Aurtsy Build Strategy & Handover Guide

**Current State**: Alpha (Functional Voice Logging & History)  
**Next Major Milestone**: "Insights" Tab (Behavioral Analytics)

---

## 1. The Mission
We are transforming Aurtsy from a simple logger into a **behavioral insight engine** for autism caregivers. The goal is to move from "What happened?" to **"Why it happened?"**.

## 2. Key Documentation (Read These First)
*   **[ANALYTICS_FRAMEWORK.md](ANALYTICS_FRAMEWORK.md)**: The core strategy for the new "Insights" tab. Defines the "Regulation Battery", "Open Loops", and "ABC Analysis".
*   **[TECHNICAL_OVERVIEW.md](TECHNICAL_OVERVIEW.md)**: Architecture, data flow, and deployment guide.
*   **[implementation_plan.md](implementation_plan.md)**: Detailed, step-by-step checklist for the current sprint.
*   **[FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md)**: Explains the iOS project structure.

---

## 3. Immediate Execution Plan (The "Insights" Sprint)

### Phase 1: Navigation & Cleanup (UI)
*   **Goal**: Prepare the app shell for the new features.
*   **Action**: 
    1.  Rename "Dashboard" tab to **"Home"**.
    2.  Simplify **History** tab: Remove charts, keep chronological feed.
    3.  Add **Detail Views** to History items (show full text & tags).

### Phase 2: The "Brain" Upgrade (AI/Backend)
*   **Goal**: Extract structured behavioral data.
*   **Action**: Update `backend/app/domains/ai/service.py` prompt to extract:
    *   **Request Status**: `GRANTED`, `DENIED`, `DELAYED`.
    *   **Food Seeking**: Distinguish "asking" from "eating".
    *   **ABC Data**: Explicit `antecedent` and `intervention` fields.

### Phase 3: The "Math" (Backend Aggregation)
*   **Goal**: Calculate insights from raw logs.
*   **Action**: Create `backend/app/domains/analytics/` with endpoints for:
    *   `get_open_loops`: List unresolved requests.
    *   `get_regulation_status`: Calculate "Battery" level.
    *   `get_correlations`: Sleep vs. Behavior, etc.

### Phase 4: The "Visuals" (iOS UI)
*   **Goal**: Display insights to the user.
*   **Action**: Create **Insights** tab with:
    *   **Regulation Battery** (Gauge view).
    *   **Open Loops Card** (List of pending requests).
    *   **Pattern Charts** (Heatmaps, Triggers).

---

## 4. Technical "Gotchas" (Warnings)

### iOS (SwiftUI)
*   **JSON Decoding**: We use `.convertFromSnakeCase`. **DO NOT** use custom `CodingKeys` in your models, or decoding will fail.
*   **Dates**: Backend returns ISO8601 with **fractional seconds**. Use the custom date strategy in `NetworkManager`.
*   **Project Structure**: The double `AurtsyApp/AurtsyApp` folder is intentional (Xcode project vs. source). Do not flatten it.

### Backend (FastAPI)
*   **Deployment**: Always run `./deploy_to_epyc.sh` to push changes to the server.
*   **LLM**: We use `qwen2.5-coder:14b-instruct` via Ollama. It is sensitive to prompt formatting.

---

## 5. Development Workflow
1.  **Edit Code**: Make changes locally.
2.  **Deploy Backend**: `./deploy_to_epyc.sh` (if backend changed).
3.  **Run iOS**: Cmd+R in Xcode.
4.  **Verify**: Check Xcode console for `🍽️`, `📊` logs.
5.  **Commit**: `git add . && git commit -m "..." && git push`.

---

**Status Check**: 
- ✅ Voice Logging works.
- ✅ History feed works.
- 🚧 Analytics/Insights is **NOT STARTED**. This is the next task.

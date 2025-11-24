# Aurtsy Caregiver Support System - Walkthrough

This guide helps you set up the newly restructured project.

## 1. Backend Setup (Epyc Server)

Navigate to the `backend/` directory and install dependencies:

```bash
cd backend
pip install -r requirements.txt
```

Run the server:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000/docs`.

## 2. AI Worker Setup (RTX 4090)

Navigate to the `ai-worker/` directory:

```bash
cd ai-worker
pip install -r requirements.txt
```

Run the worker:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

## 3. iOS App Setup (Mac Studio)

1.  Open Xcode.
2.  Create a new **SwiftUI App** project named `AurtsyApp`.
3.  Copy the files from `ios-app/` into your new Xcode project folder, replacing the default files:
    *   `AurtsyApp.swift`
    *   `ContentView.swift`
    *   `Models.swift`
    *   `NetworkManager.swift`
4.  Build and run on your Simulator or Device.

## 4. Architecture Overview

*   **Backend**: Manages Users, Children, Meals, and Activities. Stores data in PostgreSQL.
*   **AI Worker**: Analyzes images (stubbed for now) to estimate calories/behavior.
*   **iOS App**: Main interface for caregivers to log data.

## 5. Deployment to Servers

Since you have SSH access, you can use the provided script to deploy the backend and AI worker to your servers.

1.  **Make the script executable** (if not already):
    ```bash
    chmod +x deploy.sh
    ```

2.  **Run the deployment script**:
    ```bash
    ./deploy.sh
    ```
    *Note: This assumes you have `epycerver` and `pop-os` configured in your SSH config or hosts file. If not, edit `deploy.sh` with the correct IP addresses.*

3.  **Verify Remote Services**:
    *   **Backend**: `http://epycerver:8000/docs`
    *   **AI Worker**: `http://pop-os:8001/docs`

## 6. Next Steps

1.  **Database**: Ensure PostgreSQL is running and update `backend/database.py` with your credentials.
2.  **Networking**: Update `ios-app/NetworkManager.swift` with the actual IP address of your Epyc server (e.g., Tailscale IP).
3.  **AI Integration**: The AI worker is now set up to use **YOLOv8**. On the first run, it will download the model weights automatically.

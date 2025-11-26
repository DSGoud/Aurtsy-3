#!/bin/bash
# Organize iOS App Files into Modular Structure

BASE_DIR="ios-app-manual/AurtsyApp"
cd "$BASE_DIR" || exit 1

echo "📂 Organizing files in $BASE_DIR..."

# 1. Create Directories
mkdir -p Core
mkdir -p Features/Dashboard
mkdir -p Features/Meal
mkdir -p Features/Sleep
mkdir -p Features/Behavior
mkdir -p Features/Hydration
mkdir -p Features/Location
mkdir -p Features/Activity
mkdir -p Features/Child
mkdir -p Shared/Models
mkdir -p Shared/UI

# 2. Move Files

# Core
mv AurtsyApp.swift Core/
mv NetworkManager.swift Core/
[ -f "AurtsyApp-Bridging-Header.h" ] && mv "AurtsyApp-Bridging-Header.h" Core/

# Features - Dashboard
mv ContentView.swift Features/Dashboard/
mv QuickLogDashboard.swift Features/Dashboard/
mv ActivityFeedView.swift Features/Dashboard/

# Features - Meal
mv MealEntryModal.swift Features/Meal/

# Features - Sleep
mv SleepLogView.swift Features/Sleep/

# Features - Behavior
mv BehaviorLogView.swift Features/Behavior/

# Features - Hydration
mv HydrationLogView.swift Features/Hydration/

# Features - Location
mv LocationCheckView.swift Features/Location/

# Features - Activity
mv ActivityLogView.swift Features/Activity/

# Features - Child
mv ChildManagementView.swift Features/Child/

# Shared - Models
mv Models.swift Shared/Models/

# Shared - UI
mv ModernHeader.swift Shared/UI/
mv PrimaryCapsule.swift Shared/UI/

echo "✅ Files organized successfully!"
echo "⚠️  REMINDER: Open Xcode, delete red files, and drag new folders into the project."

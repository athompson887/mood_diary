#!/bin/bash

# Android Screenshot Helper Script
# This script helps you take screenshots manually by guiding you through each screen
#
# Copyright (c) 2025 Andrew Thompson
# All rights reserved.

# Set ADB path
ADB="$HOME/Library/Android/sdk/platform-tools/adb"

# Check if adb exists
if [ ! -f "$ADB" ]; then
    echo "❌ adb not found at $ADB"
    echo "Please check your Android SDK installation"
    exit 1
fi

echo "📸 Android Screenshot Helper"
echo "=============================="
echo ""
echo "This script will help you capture screenshots for Google Play Store."
echo "Make sure your emulator is running and your app is open."
echo ""

# Check if emulator is running
if ! $ADB devices | grep -q "emulator"; then
    echo "❌ No emulator detected!"
    echo "Please start your emulator first:"
    echo "   flutter emulators --launch Pixel_9a"
    exit 1
fi

echo "✅ Emulator detected"
echo ""

# Create screenshots directory
mkdir -p fastlane/screenshots/android
echo "📁 Created fastlane/screenshots/android/"
echo ""

echo "================================================"
echo "Ready to take screenshots!"
echo "================================================"
echo ""
echo "Instructions:"
echo "1. Navigate to each screen in your app as prompted"
echo "2. Press ENTER when you're ready to capture"
echo "3. The script will save the screenshot automatically"
echo ""
echo "Press ENTER to start..."
read

# Screenshot 1: Home Screen
echo ""
echo "📱 Screenshot 1/5: HOME SCREEN"
echo "Navigate to the main home screen (stress bucket overview)"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/01_home_screen.png
echo "✅ Saved: 01_home_screen.png"
sleep 1

# Screenshot 2: Timeline
echo ""
echo "📱 Screenshot 2/5: TIMELINE SCREEN"
echo "Tap on the Timeline/History tab at the bottom"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/02_timeline.png
echo "✅ Saved: 02_timeline.png"
sleep 1

# Screenshot 3: Insights
echo ""
echo "📱 Screenshot 3/5: INSIGHTS SCREEN"
echo "Tap on the Insights tab at the bottom"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/03_insights.png
echo "✅ Saved: 03_insights.png"
sleep 1

# Screenshot 4: More/Settings
echo ""
echo "📱 Screenshot 4/5: MORE/SETTINGS SCREEN"
echo "Tap on the More tab at the bottom"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/04_more.png
echo "✅ Saved: 04_more.png"
sleep 1

# Screenshot 5: Add Stressor
echo ""
echo "📱 Screenshot 5/5: ADD STRESSOR SCREEN"
echo "Tap the + (add) button to open the add stressor screen"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/05_add_stressor.png
echo "✅ Saved: 05_add_stressor.png"
sleep 1

echo ""
echo "================================================"
echo "✨ All screenshots captured successfully!"
echo "================================================"
echo ""
echo "Screenshots saved to: fastlane/screenshots/android/"
echo ""
echo "Next steps:"
echo "1. Review the screenshots to make sure they look good"
echo "2. If any need retaking, you can run this script again"
echo "3. Upload to Google Play Console when ready"
echo ""

# List the captured screenshots
echo "Captured files:"
ls -lh fastlane/screenshots/android/*.png 2>/dev/null || echo "No screenshots found"

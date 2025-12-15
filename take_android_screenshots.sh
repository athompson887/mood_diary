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
echo ""

# Show recommended devices
echo "📱 Recommended emulators for Google Play screenshots:"
echo ""
echo "  PHONES (required - at least one):"
echo "    • Pixel 9 Pro XL    - 1344 x 2992 (latest flagship)"
echo "    • Pixel 8 Pro       - 1344 x 2992"
echo "    • Pixel 9           - 1080 x 2424"
echo "    • Pixel 8           - 1080 x 2400"
echo ""
echo "  TABLETS (optional):"
echo "    • Pixel Tablet      - 2560 x 1600 (10\" tablet)"
echo "    • Medium Tablet     - 2560 x 1600 (7\" tablet)"
echo ""
echo "  Google Play requires:"
echo "    • Phone: min 1080px wide, 16:9 or taller"
echo "    • 7\" tablet: 1024 x 500 min (optional)"
echo "    • 10\" tablet: 1280 x 800 min (optional)"
echo ""

# Check if emulator is running
if ! $ADB devices | grep -q "emulator"; then
    echo "❌ No emulator detected!"
    echo ""
    echo "Start an emulator with one of these commands:"
    echo "   flutter emulators --launch Pixel_9_Pro_XL_API_35"
    echo "   flutter emulators --launch Pixel_8_Pro_API_35"
    echo "   flutter emulators --launch Pixel_9_API_35"
    echo ""
    echo "Or list available emulators:"
    echo "   flutter emulators"
    exit 1
fi

echo "✅ Emulator detected"
echo ""

# Create screenshots directory
mkdir -p fastlane/screenshots/android
echo "📁 Screenshots will be saved to: fastlane/screenshots/android/"
echo ""

echo "================================================"
echo "Ready to take screenshots!"
echo "================================================"
echo ""
echo "Instructions:"
echo "1. Make sure your app is open on the emulator"
echo "2. Navigate to each screen as prompted"
echo "3. Press ENTER when you're ready to capture"
echo ""
echo "Press ENTER to start..."
read

# Screenshot 1: Home Screen
echo ""
echo "📱 Screenshot 1/6: TODAY SCREEN"
echo "Navigate to the Today tab (home screen showing today's mood)"
echo "Tip: Best with a mood already logged to show the emoji and mood label"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/01_today.png
echo "✅ Saved: 01_today.png"
sleep 1

# Screenshot 2: Add Mood
echo ""
echo "📱 Screenshot 2/6: ADD MOOD SCREEN"
echo "Tap the 'Log Mood' button to open the mood entry screen"
echo "Select a mood emoji to show the mood selector in action"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/02_add_mood.png
echo "✅ Saved: 02_add_mood.png"
sleep 1

# Screenshot 3: History Calendar
echo ""
echo "📱 Screenshot 3/6: HISTORY SCREEN"
echo "Tap on the History tab at the bottom (calendar icon)"
echo "Shows the calendar view with mood entries marked"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/03_statistics.png
echo "✅ Saved: 03_history.png"
sleep 1

# Screenshot 4: Statistics
echo ""
echo "📱 Screenshot 4/6: STATISTICS SCREEN"
echo "Tap on the Statistics tab at the bottom (chart icon)"
echo "Shows mood trends, averages, and insights"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/04_statistics.png
echo "✅ Saved: 04_statistics.png"
sleep 1

# Screenshot 5: More Menu
echo ""
echo "📱 Screenshot 5/6: MORE MENU"
echo "Tap on the More tab at the bottom"
echo "Shows settings, accessibility, and other options"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/05_more.png
echo "✅ Saved: 05_more.png"
sleep 1

# Screenshot 6: Accessibility Settings
echo ""
echo "📱 Screenshot 6/6: ACCESSIBILITY SETTINGS"
echo "From More menu, tap 'Accessibility' to show accessibility options"
echo "Shows high contrast, dyslexia font, and other accessibility features"
echo "Press ENTER when ready..."
read
$ADB exec-out screencap -p > fastlane/screenshots/android/06_accessibility.png
echo "✅ Saved: 06_accessibility.png"
sleep 1

echo ""
echo "================================================"
echo "✨ All 6 screenshots captured successfully!"
echo "================================================"
echo ""
echo "Screenshots saved to: fastlane/screenshots/android/"
echo ""
echo "Captured screens:"
echo "  1. Today - Home screen with mood display"
echo "  2. Add Mood - Mood entry with emoji selector"
echo "  3. History - Calendar view of mood entries"
echo "  4. Statistics - Mood trends and insights"
echo "  5. More - Settings and options menu"
echo "  6. Accessibility - Accessibility features"
echo ""
echo "Next steps:"
echo "1. Review the screenshots to make sure they look good"
echo "2. If any need retaking, you can run this script again"
echo "3. Upload to Google Play Console when ready"
echo ""

# List the captured screenshots
echo "Captured files:"
ls -lh fastlane/screenshots/android/*.png 2>/dev/null || echo "No screenshots found"

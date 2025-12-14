#!/bin/bash

# Enhanced Android Screenshot Script
# Supports multiple devices and comprehensive feature coverage
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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 Enhanced Android Screenshot Tool${NC}"
echo "============================================"
echo ""

# Show available emulators
echo -e "${YELLOW}Select device type for screenshots:${NC}"
echo "1) Phone (e.g., Pixel 9, Pixel 5, etc.)"
echo "2) 7\" Tablet (e.g., Nexus 7)"
echo "3) 10\" Tablet (e.g., Pixel Tablet, larger tablets)"
echo ""
read -p "Enter choice [1-3]: " DEVICE_CHOICE
echo ""

# Set expected device type and recommendations
case $DEVICE_CHOICE in
    1)
        EXPECTED_TYPE="phone"
        echo -e "${BLUE}📱 Phone selected${NC}"
        echo "Recommended emulators:"
        echo "  • Pixel_9a"
        echo "  • Pixel_5"
        echo "  • Any phone-sized device"
        ;;
    2)
        EXPECTED_TYPE="tablet_7"
        echo -e "${BLUE}📱 7\" Tablet selected${NC}"
        echo "Recommended emulators:"
        echo "  • Nexus_7"
        echo "  • Any 7-inch tablet device"
        ;;
    3)
        EXPECTED_TYPE="tablet_10"
        echo -e "${BLUE}📱 10\" Tablet selected${NC}"
        echo "Recommended emulators:"
        echo "  • Pixel_Tablet"
        echo "  • Medium_Tablet_API_35"
        echo "  • Any 10-inch tablet device"
        ;;
    *)
        EXPECTED_TYPE="phone"
        echo -e "${YELLOW}⚠️  Invalid choice, defaulting to phone${NC}"
        ;;
esac

echo ""
echo -e "${YELLOW}Available emulators on your system:${NC}"
flutter emulators
echo ""

echo -e "${BLUE}Please start the appropriate emulator for ${EXPECTED_TYPE}${NC}"
echo "Use: flutter emulators --launch <emulator_id>"
echo ""
read -p "Press ENTER once your emulator is running and the app is open..."

# Check if emulator is running
if ! $ADB devices | grep -q "device$"; then
    echo -e "${RED}❌ No device/emulator detected!${NC}"
    echo "Please start your emulator first:"
    echo "   flutter emulators"
    echo "   flutter emulators --launch <emulator_id>"
    exit 1
fi

# Get device model and screen size
DEVICE_MODEL=$($ADB shell getprop ro.product.model | tr -d '\r')
DEVICE_NAME=$($ADB shell getprop ro.product.name | tr -d '\r')
SCREEN_DENSITY=$($ADB shell wm density | cut -d' ' -f3 | tr -d '\r')
SCREEN_SIZE=$($ADB shell wm size | cut -d' ' -f3 | tr -d '\r')

echo ""
echo -e "${GREEN}✅ Device detected${NC}"
echo "   Model: $DEVICE_MODEL"
echo "   Name: $DEVICE_NAME"
echo "   Screen: $SCREEN_SIZE"
echo "   Density: ${SCREEN_DENSITY}dpi"
echo ""

# Determine device type by calculating physical screen size
WIDTH=$(echo $SCREEN_SIZE | cut -d'x' -f1)
HEIGHT=$(echo $SCREEN_SIZE | cut -d'x' -f2)

# Calculate diagonal screen size in inches
# diagonal = sqrt(width^2 + height^2) / dpi
WIDTH_SQ=$((WIDTH * WIDTH))
HEIGHT_SQ=$((HEIGHT * HEIGHT))
DIAGONAL_PX=$(echo "sqrt($WIDTH_SQ + $HEIGHT_SQ)" | bc)
DIAGONAL_INCHES=$(echo "scale=2; $DIAGONAL_PX / $SCREEN_DENSITY" | bc)

echo "Calculated screen size: ${DIAGONAL_INCHES} inches"
echo ""

# Classify device based on diagonal size
# Phones: < 7 inches
# 7" tablets: 7-9 inches
# 10" tablets: >= 9 inches
DIAGONAL_INT=$(echo "$DIAGONAL_INCHES" | cut -d'.' -f1)

if [ "$DIAGONAL_INT" -ge 9 ]; then
    DEVICE_TYPE="tablet_10"
elif [ "$DIAGONAL_INT" -ge 7 ]; then
    DEVICE_TYPE="tablet_7"
else
    DEVICE_TYPE="phone"
fi

# Warn if detected device doesn't match expected
if [ "$DEVICE_TYPE" != "$EXPECTED_TYPE" ]; then
    echo -e "${YELLOW}⚠️  Warning: Detected device type ($DEVICE_TYPE) doesn't match your selection ($EXPECTED_TYPE)${NC}"
    read -p "Continue anyway? [y/N]: " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Exiting. Please start the correct emulator and run again."
        exit 1
    fi
    echo ""
fi

# Create a clean folder name
FOLDER_NAME="${DEVICE_TYPE}_$(echo $DEVICE_MODEL | tr ' ' '_' | tr '[:upper:]' '[:lower:]')"
OUTPUT_DIR="fastlane/screenshots/android/${FOLDER_NAME}"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}📁 Created: $OUTPUT_DIR${NC}"
echo ""

# Screenshot mode selection
echo -e "${YELLOW}Select screenshot mode:${NC}"
echo "1) Quick Mode (5 essential screens)"
echo "2) Standard Mode (10 screens including games)"
echo "3) Complete Mode (15+ screens - all features)"
echo ""
read -p "Enter choice [1-3]: " MODE

case $MODE in
    1) SCREENSHOT_MODE="quick" ;;
    2) SCREENSHOT_MODE="standard" ;;
    3) SCREENSHOT_MODE="complete" ;;
    *) SCREENSHOT_MODE="quick" ;;
esac

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Ready to capture screenshots in ${SCREENSHOT_MODE} mode!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Instructions:"
echo "1. Navigate to each screen in your app as prompted"
echo "2. Press ENTER when you're ready to capture"
echo "3. Screenshots will be saved to: $OUTPUT_DIR"
echo ""
read -p "Press ENTER to start..."

# Counter for screenshots
COUNT=0

# Function to take screenshot
take_screenshot() {
    local filename=$1
    local description=$2
    COUNT=$((COUNT + 1))

    echo ""
    echo -e "${BLUE}📱 Screenshot $COUNT: $description${NC}"
    echo "$3"
    read -p "Press ENTER when ready..."

    $ADB exec-out screencap -p > "$OUTPUT_DIR/$filename"

    if [ $? -eq 0 ]; then
        SIZE=$(ls -lh "$OUTPUT_DIR/$filename" | awk '{print $5}')
        echo -e "${GREEN}✅ Saved: $filename ($SIZE)${NC}"
    else
        echo -e "${RED}❌ Failed to capture $filename${NC}"
    fi

    sleep 0.5
}

# QUICK MODE (5 screens)
take_screenshot "01_home_screen.png" "HOME SCREEN" "Navigate to the main home screen (stress bucket overview)"
take_screenshot "02_timeline.png" "TIMELINE SCREEN" "Tap on the Timeline tab at the bottom navigation"
take_screenshot "03_insights.png" "INSIGHTS SCREEN" "Tap on the Insights tab"
take_screenshot "04_add_stressor.png" "ADD STRESSOR" "Tap the + button, then 'Add Stressor' to open the add stressor dialog"
take_screenshot "05_more_menu.png" "MORE MENU" "Tap on the More tab to show settings and options"

# STANDARD MODE (10 screens - includes games)
if [ "$SCREENSHOT_MODE" != "quick" ]; then
    take_screenshot "06_history_screen.png" "HISTORY SCREEN (Pensieve)" "From More menu, tap 'History' or navigate to History screen"
    take_screenshot "07_activity_selection.png" "ACTIVITY SELECTION" "Go back to home, tap a coping activity or navigate to activity selection"
    take_screenshot "08_game_bubble_wrap.png" "GAME: Bubble Wrap" "From activity selection, choose and open Bubble Wrap game"
    take_screenshot "09_game_zen_garden.png" "GAME: Zen Garden" "Navigate back, then open Zen Garden game"
    take_screenshot "10_accessibility.png" "ACCESSIBILITY SETTINGS" "Go to More → Accessibility to show accessibility features"
fi

# COMPLETE MODE (15+ screens - all features)
if [ "$SCREENSHOT_MODE" == "complete" ]; then
    take_screenshot "11_add_coping.png" "ADD COPING ACTION" "Tap + button, then 'Add Coping' to open add coping dialog"
    take_screenshot "12_game_balloon_pop.png" "GAME: Balloon Pop" "Open Balloon Pop game from activities"
    take_screenshot "13_game_breathing_bubble.png" "GAME: Breathing Bubble" "Open Breathing Bubble game"
    take_screenshot "14_game_cloud_gazing.png" "GAME: Cloud Gazing" "Open Cloud Gazing game"
    take_screenshot "15_settings.png" "SETTINGS SCREEN" "Go to More → Settings"

    echo ""
    echo -e "${YELLOW}Optional: Premium features (if available)${NC}"
    read -p "Do you want to capture premium/paywall screenshots? [y/N]: " CAPTURE_PREMIUM

    if [[ $CAPTURE_PREMIUM =~ ^[Yy]$ ]]; then
        take_screenshot "16_paywall.png" "PAYWALL SCREEN" "Navigate to paywall/subscription screen"
        take_screenshot "17_subscription_management.png" "SUBSCRIPTION MANAGEMENT" "If subscribed, show subscription management"
    fi
fi

# Summary
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✨ Screenshot capture complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "Device: ${BLUE}$DEVICE_MODEL${NC}"
echo -e "Mode: ${BLUE}$SCREENSHOT_MODE${NC}"
echo -e "Total screenshots: ${BLUE}$COUNT${NC}"
echo -e "Location: ${BLUE}$OUTPUT_DIR${NC}"
echo ""

# List captured screenshots
echo "Captured files:"
ls -lh "$OUTPUT_DIR"/*.png 2>/dev/null | awk '{printf "  %-40s %s\n", $9, $5}'

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review screenshots in: $OUTPUT_DIR"
echo "2. Repeat on other devices (phones/tablets) as needed"
echo "3. Upload to Google Play Console when ready"
echo ""

# Suggest capturing other device types
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📱 Capture screenshots for other device types?${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Google Play Store recommends screenshots for:"
echo "  • At least one phone (✓ if you selected phone)"
echo "  • At least one 7\" tablet"
echo "  • At least one 10\" tablet"
echo ""
read -p "Do you want to capture screenshots on another device type now? [y/N]: " CAPTURE_MORE

if [[ $CAPTURE_MORE =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}To capture on another device:${NC}"
    echo "1. Close the current emulator"
    echo "2. Run this script again: ./take_screenshots_enhanced.sh"
    echo "3. Select a different device type"
    echo ""
else
    echo ""
    echo -e "${GREEN}Great! Remember to capture screenshots on different device types${NC}"
    echo -e "${GREEN}by running this script again with other emulators.${NC}"
    echo ""
fi

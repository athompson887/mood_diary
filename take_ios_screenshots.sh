#!/bin/bash

# iOS Screenshot Script for App Store
# Supports multiple devices and comprehensive feature coverage
#
# Copyright (c) 2025 Andrew Thompson
# All rights reserved.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 iOS Screenshot Tool for App Store${NC}"
echo "============================================"
echo ""

# Show available simulators
echo -e "${YELLOW}Select device type for screenshots:${NC}"
echo "1) iPhone (6.7\" display - iPhone 16 Pro Max / 16 Plus)"
echo "2) iPhone (6.1\" display - iPhone 16 Pro / 16)"
echo "3) iPhone (Small - iPhone SE 3rd generation)"
echo "4) iPad (12.9\" - iPad Pro 13-inch M4)"
echo "5) iPad (11\" - iPad Pro 11-inch M4 / iPad Air 11-inch)"
echo ""
read -p "Enter choice [1-5]: " DEVICE_CHOICE
echo ""

# Set expected device type and recommendations
case $DEVICE_CHOICE in
    1)
        EXPECTED_TYPE="iphone_67"
        DEVICE_NAME="iPhone 16 Pro Max"
        echo -e "${BLUE}📱 iPhone 6.7\" selected${NC}"
        echo "Recommended simulators:"
        echo "  • iPhone 16 Pro Max"
        echo "  • iPhone 16 Plus"
        ;;
    2)
        EXPECTED_TYPE="iphone_61"
        DEVICE_NAME="iPhone 16 Pro"
        echo -e "${BLUE}📱 iPhone 6.1\" selected${NC}"
        echo "Recommended simulators:"
        echo "  • iPhone 16 Pro"
        echo "  • iPhone 16"
        ;;
    3)
        EXPECTED_TYPE="iphone_small"
        DEVICE_NAME="iPhone SE (3rd generation)"
        echo -e "${BLUE}📱 iPhone Small selected${NC}"
        echo "Recommended simulators:"
        echo "  • iPhone SE (3rd generation)"
        ;;
    4)
        EXPECTED_TYPE="ipad_129"
        DEVICE_NAME="iPad Pro 13-inch (M4)"
        echo -e "${BLUE}📱 iPad 12.9\" selected${NC}"
        echo "Recommended simulators:"
        echo "  • iPad Pro 13-inch (M4)"
        ;;
    5)
        EXPECTED_TYPE="ipad_11"
        DEVICE_NAME="iPad Pro 11-inch (M4)"
        echo -e "${BLUE}📱 iPad 11\" selected${NC}"
        echo "Recommended simulators:"
        echo "  • iPad Pro 11-inch (M4)"
        echo "  • iPad Air 11-inch (M2)"
        ;;
    *)
        EXPECTED_TYPE="iphone_67"
        DEVICE_NAME="iPhone 16 Pro Max"
        echo -e "${YELLOW}⚠️  Invalid choice, defaulting to iPhone 6.7\"${NC}"
        ;;
esac

echo ""
echo -e "${YELLOW}Available iOS simulators on your system:${NC}"
xcrun simctl list devices available | grep -E "iPhone|iPad" | head -20
echo ""

echo -e "${BLUE}Starting simulator: ${DEVICE_NAME}${NC}"
echo "Booting ${DEVICE_NAME}..."

# Find the simulator UUID for the selected device (prefer latest iOS version)
SIMULATOR_UUID=$(xcrun simctl list devices available | grep "$DEVICE_NAME" | tail -1 | grep -o '([0-9A-F-]*' | tr -d '(')

if [ -z "$SIMULATOR_UUID" ]; then
    echo -e "${RED}❌ Simulator not found: ${DEVICE_NAME}${NC}"
    echo "Available simulators:"
    xcrun simctl list devices available | grep -E "iPhone|iPad"
    echo ""
    echo "Please manually start your desired simulator, then press ENTER to continue..."
    read
else
    # Boot the simulator
    xcrun simctl boot "$SIMULATOR_UUID" 2>/dev/null || true
    sleep 3

    # Open Simulator app
    open -a Simulator
    sleep 5

    echo -e "${GREEN}✅ Simulator started${NC}"
fi

echo ""
echo -e "${BLUE}Please ensure your app is running on the simulator${NC}"
echo "Use: flutter run"
echo ""
read -p "Press ENTER once your app is open and ready for screenshots..."

# Create output directory
FOLDER_NAME="${EXPECTED_TYPE}_$(echo $DEVICE_NAME | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -d '()')"
OUTPUT_DIR="fastlane/screenshots/ios/${FOLDER_NAME}"
mkdir -p "$OUTPUT_DIR"

echo ""
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

    # Always capture from any booted simulator (more reliable)
    xcrun simctl io booted screenshot "$OUTPUT_DIR/$filename"

    if [ $? -eq 0 ]; then
        SIZE=$(ls -lh "$OUTPUT_DIR/$filename" | awk '{print $5}')
        echo -e "${GREEN}✅ Saved: $filename ($SIZE)${NC}"
    else
        echo -e "${RED}❌ Failed to capture $filename${NC}"
        echo -e "${YELLOW}Make sure a simulator is running and visible${NC}"
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
echo -e "Device: ${BLUE}$DEVICE_NAME${NC}"
echo -e "Type: ${BLUE}$EXPECTED_TYPE${NC}"
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
echo "2. Repeat on other devices (different iPhones/iPads) as needed"
echo "3. Upload to App Store Connect when ready"
echo ""

# Suggest capturing other device types
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📱 Capture screenshots for other device types?${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "App Store recommends screenshots for:"
echo "  • At least one 6.7\" iPhone (iPhone Pro Max/Plus)"
echo "  • Optional: 6.1\" iPhone (iPhone Pro/regular)"
echo "  • Optional: iPad (12.9\" or 11\")"
echo ""
read -p "Do you want to capture screenshots on another device type now? [y/N]: " CAPTURE_MORE

if [[ $CAPTURE_MORE =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}To capture on another device:${NC}"
    echo "1. The script will close the current simulator"
    echo "2. Run this script again: ./take_ios_screenshots.sh"
    echo "3. Select a different device type"
    echo ""
    read -p "Close current simulator now? [y/N]: " CLOSE_SIM

    if [[ $CLOSE_SIM =~ ^[Yy]$ ]]; then
        if [ ! -z "$SIMULATOR_UUID" ]; then
            xcrun simctl shutdown "$SIMULATOR_UUID"
            echo -e "${GREEN}✅ Simulator closed${NC}"
        else
            xcrun simctl shutdown booted
            echo -e "${GREEN}✅ Simulator(s) closed${NC}"
        fi
    fi
else
    echo ""
    echo -e "${GREEN}Great! Remember to capture screenshots on different device types${NC}"
    echo -e "${GREEN}by running this script again with other simulators.${NC}"
    echo ""
fi

#!/bin/bash

# Batch Screenshot Resizer for App Store & Play Store
# Resizes screenshots to meet exact store requirements
#
# Copyright (c) 2025 Andrew Thompson
# All rights reserved.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📐 Screenshot Batch Resizer${NC}"
echo "============================================"
echo ""

# Base directory for screenshots
IOS_DIR="fastlane/screenshots/ios"
ANDROID_DIR="fastlane/screenshots/android"

# Create backup directory
BACKUP_DIR="fastlane/screenshots/backups_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}Select platform:${NC}"
echo "1) iOS (App Store)"
echo "2) Android (Play Store)"
echo "3) Both"
echo ""
read -p "Enter choice [1-3]: " PLATFORM_CHOICE
echo ""

resize_ios() {
    echo -e "${BLUE}🍎 Resizing iOS screenshots for App Store${NC}"
    echo ""

    if [ ! -d "$IOS_DIR" ]; then
        echo -e "${RED}❌ iOS screenshots directory not found${NC}"
        return
    fi

    total_resized=0

    # Process each iOS screenshot folder
    for folder in "$IOS_DIR"/*; do
        if [ ! -d "$folder" ]; then
            continue
        fi

        folder_name=$(basename "$folder")

        # Determine target size based on folder name using case statement
        target_size=""
        case "$folder_name" in
            iphone_67*)
                target_size="1284x2778"  # iPhone 6.7" (Pro Max) - Portrait
                ;;
            iphone_65*)
                target_size="1242x2688"  # iPhone 6.5" (older Pro Max) - Portrait
                ;;
            iphone_61*)
                target_size="1284x2778"  # iPhone 6.1" (Pro) - Use 6.7" size
                ;;
            iphone_small*)
                target_size="1284x2778"  # Use 6.7" size for small phones
                ;;
            ipad_129*|ipad_13*)
                target_size="2048x2732"  # iPad Pro 12.9" or 13" - Portrait (2048×2732 or 2064×2752)
                ;;
            ipad_11*)
                target_size="2048x2732"  # iPad 11" - Use 12.9" size for compatibility
                ;;
            *)
                echo -e "${YELLOW}⚠️  Skipping $folder_name (unknown device type)${NC}"
                continue
                ;;
        esac

        echo -e "${GREEN}Processing: $folder_name → $target_size${NC}"

        # Backup original screenshots
        backup_folder="$BACKUP_DIR/ios/$(basename "$folder")"
        mkdir -p "$backup_folder"
        cp -r "$folder"/*.png "$backup_folder/" 2>/dev/null

        # Resize all PNG files in folder
        for screenshot in "$folder"/*.png; do
            if [ -f "$screenshot" ]; then
                filename=$(basename "$screenshot")

                # Get current dimensions
                current_width=$(sips -g pixelWidth "$screenshot" | tail -1 | awk '{print $2}')
                current_height=$(sips -g pixelHeight "$screenshot" | tail -1 | awk '{print $2}')
                current_size="${current_width}x${current_height}"

                # Extract target dimensions
                target_width=$(echo "$target_size" | cut -d'x' -f1)
                target_height=$(echo "$target_size" | cut -d'x' -f2)

                # Resize if needed
                if [ "$current_size" != "$target_size" ]; then
                    sips -z "$target_height" "$target_width" "$screenshot" > /dev/null 2>&1

                    if [ $? -eq 0 ]; then
                        echo "  ✓ $filename: $current_size → $target_size"
                        total_resized=$((total_resized + 1))
                    else
                        echo -e "  ${RED}✗ Failed to resize $filename${NC}"
                    fi
                else
                    echo "  ↻ $filename: Already correct size"
                fi
            fi
        done
        echo ""
    done

    echo -e "${GREEN}✅ iOS: Resized $total_resized screenshots${NC}"
    echo ""
}

resize_android() {
    echo -e "${BLUE}🤖 Resizing Android screenshots for Play Store${NC}"
    echo ""

    if [ ! -d "$ANDROID_DIR" ]; then
        echo -e "${RED}❌ Android screenshots directory not found${NC}"
        return
    fi

    # Google Play accepts various sizes, but recommends:
    # - 16:9 aspect ratio (landscape or portrait)
    # - Min: 320px on shortest side
    # - Max: 3840px on longest side
    # Common recommended sizes:
    # - Phone: 1080x1920, 1440x2560
    # - 7" Tablet: 1200x1920
    # - 10" Tablet: 1600x2560

    total_resized=0

    # Process each Android screenshot folder
    for folder in "$ANDROID_DIR"/*; do
        if [ ! -d "$folder" ]; then
            continue
        fi

        folder_name=$(basename "$folder")

        # Determine target size based on folder name using case statement
        target_size=""
        case "$folder_name" in
            phone*)
                target_size="1080x1920"  # Standard phone portrait
                ;;
            tablet_7*)
                target_size="1200x1920"  # 7" tablet portrait
                ;;
            tablet_10*)
                target_size="1600x2560"  # 10" tablet portrait
                ;;
            *)
                echo -e "${YELLOW}⚠️  Skipping $folder_name (unknown device type)${NC}"
                continue
                ;;
        esac

        echo -e "${GREEN}Processing: $folder_name → $target_size${NC}"

        # Backup original screenshots
        backup_folder="$BACKUP_DIR/android/$(basename "$folder")"
        mkdir -p "$backup_folder"
        cp -r "$folder"/*.png "$backup_folder/" 2>/dev/null

        # Resize all PNG files in folder
        for screenshot in "$folder"/*.png; do
            if [ -f "$screenshot" ]; then
                filename=$(basename "$screenshot")

                # Get current dimensions
                current_width=$(sips -g pixelWidth "$screenshot" | tail -1 | awk '{print $2}')
                current_height=$(sips -g pixelHeight "$screenshot" | tail -1 | awk '{print $2}')
                current_size="${current_width}x${current_height}"

                # Extract target dimensions
                target_width=$(echo "$target_size" | cut -d'x' -f1)
                target_height=$(echo "$target_size" | cut -d'x' -f2)

                # Resize if needed
                if [ "$current_size" != "$target_size" ]; then
                    sips -z "$target_height" "$target_width" "$screenshot" > /dev/null 2>&1

                    if [ $? -eq 0 ]; then
                        echo "  ✓ $filename: $current_size → $target_size"
                        total_resized=$((total_resized + 1))
                    else
                        echo -e "  ${RED}✗ Failed to resize $filename${NC}"
                    fi
                else
                    echo "  ↻ $filename: Already correct size"
                fi
            fi
        done
        echo ""
    done

    echo -e "${GREEN}✅ Android: Resized $total_resized screenshots${NC}"
    echo ""
}

# Execute based on choice
case $PLATFORM_CHOICE in
    1)
        resize_ios
        ;;
    2)
        resize_android
        ;;
    3)
        resize_ios
        resize_android
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}✨ Batch resize complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Backups saved to: $BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review resized screenshots to ensure quality"
echo "2. Upload to stores:"
echo "   iOS: cd fastlane && fastlane ios upload_screenshots"
echo "   Android: Upload manually or use fastlane"
echo ""
echo "To restore from backup if needed:"
echo "  cp -r $BACKUP_DIR/ios/* $IOS_DIR/"
echo "  cp -r $BACKUP_DIR/android/* $ANDROID_DIR/"
echo ""

#!/bin/bash

# Base directory for the client project
CLIENT_DIR="/Users/jose.frometa/.gemini/antigravity/scratch/esquizo/client"
LIB_DIR="$CLIENT_DIR/lib"

# List of renames (old:new)
RENAMES=(
    "landing-page-home.dart:landing_page_home.dart"
    "catering-details-content.dart:catering_details_content.dart"
    "catering-section.dart:catering_section.dart"
    "contact-section.dart:contact_section.dart"
    "content-sections.dart:content_sections.dart"
    "events-section.dart:events_section.dart"
    "features-section.dart:features_section.dart"
    "footer-section.dart:footer_section.dart"
    "hero-section.dart:hero_section.dart"
    "meal-plans-section.dart:meal_plans_section.dart"
    "menu-section.dart:menu_section.dart"
    "quick-access-section.dart:quick_access_section.dart"
    "reservation-section.dart:reservation_section.dart"
    "restaurant-info-section.dart:restaurant_info_section.dart"
    "plan-card.dart:plan_card.dart"
    "responsive-section.dart:responsive_section.dart"
)

echo "Starting safe renaming..."

for item in "${RENAMES[@]}"; do
    old_name="${item%%:*}"
    new_name="${item##*:}"
    
    old_file_path=$(find "$LIB_DIR" -name "$old_name" -type f)
    
    if [ -n "$old_file_path" ]; then
        new_file_path="${old_file_path%/*}/$new_name"
        echo "Renaming $old_file_path to $new_file_path"
        mv "$old_file_path" "$new_file_path"
        
        # Update imports in all dart files
        echo "Updating imports for $old_name -> $new_name"
        find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' "s/$old_name/$new_name/g" {} +
    fi
done

echo "Safe renaming complete."

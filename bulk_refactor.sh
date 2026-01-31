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

echo "Starting bulk refactoring..."

# 1. Rename files and update imports
for item in "${RENAMES[@]}"; do
    old_name="${item%%:*}"
    new_name="${item##*:}"
    
    # Find the file
    old_file_path=$(find "$LIB_DIR" -name "$old_name" -type f)
    
    if [ -f "$old_file_path" ]; then
        new_file_path="${old_file_path%/*}/$new_name"
        echo "Renaming $old_file_path to $new_file_path"
        mv "$old_file_path" "$new_file_path"
        
        # Update imports in all dart files
        echo "Updating imports for $old_name -> $new_name"
        find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' "s/$old_name/$new_name/g" {} +
    else
        echo "Warning: File $old_name not found."
    fi
done

# 2. Bulk replace withOpacity -> withValues(alpha: ...)
echo "Replacing withOpacity with withValues(alpha: ...)"
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' 's/withOpacity(\([^)]*\))/withValues(alpha: \1)/g' {} +

# 3. Bulk replace deprecated Ref names
echo "Replacing deprecated Riverpod Ref names..."
REFS=(
    "OnboardingRepositoryRef"
    "CurrentBusinessNavigationRef"
    "ShouldOptimizeNavigationRef"
    "CurrentRouteLocationRef"
    "IsBusinessUrlAccessRef"
    "BusinessRoutePrefixRef"
)

for ref in "${REFS[@]}"; do
    find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' "s/$ref/Ref/g" {} +
done

# 4. Bulk replace deprecated Providers
echo "Replacing deprecated Firebase Providers..."
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' 's/androidProvider/providerAndroid/g' {} +
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' 's/appleProvider/providerApple/g' {} +

echo "Bulk refactoring complete."

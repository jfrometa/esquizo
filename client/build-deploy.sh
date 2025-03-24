#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

# Build Flutter web app with the PWA strategy disabled
flutter build web --pwa-strategy=none

# Add cache busting to main.dart.js (the most important file)
# This appends a query param with the build ID to force cache invalidation
if [ -f "build/web/index.html" ]; then
  # Replace the main.dart.js reference to include the build ID
  sed -i.bak "s/main\.dart\.js/main.dart.js?v=$BUILD_ID/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add build ID to the page for debugging purposes
  echo "<!-- Build: $BUILD_ID -->" >> build/web/index.html
  echo "✅ Cache busting applied with build ID: $BUILD_ID"
else
  echo "❌ Could not find index.html file"
  exit 1
fi

echo "🚀 Build completed successfully with cache busting"
# Note: The GitHub Action will handle the deployment
#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

# Build Flutter web app with enhanced options for optimization and security
flutter build web --release --pwa-strategy=offline-first --dart-define=Dart2jsOptimization=O4 --csp

# Add cache busting to main.dart.js (the most important file)
# This appends a query param with the build ID to force cache invalidation
if [ -f "build/web/index.html" ]; then
  # Replace the main.dart.js reference to include the build ID
  sed -i.bak "s/main\.dart\.js/main.dart.js?v=$BUILD_ID/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add cache busting to all JS files
  sed -i.bak -E "s/([a-zA-Z0-9_]+\.js)(\"|')/\1?v=$BUILD_ID\2/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add build ID to the page for debugging purposes
  echo "<!-- Build: $BUILD_ID - $(date) -->" >> build/web/index.html
  echo "✅ Cache busting applied with build ID: $BUILD_ID"
else
  echo "❌ Could not find index.html file"
  exit 1
fi

echo "🚀 Build completed successfully with cache busting"
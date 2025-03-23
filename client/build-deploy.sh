#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

# Build Flutter web app with the PWA strategy disabled
flutter build web --pwa-strategy=none

# Check if build succeeded
if [ -f "build/web/index.html" ]; then
  echo "✅ Build completed successfully"
  
  # Add cache busting to all JavaScript files referenced in index.html
  # This includes main.dart.js and flutter_bootstrap.js
  sed -i.bak -E "s/([a-zA-Z0-9_]+\.js)(\"|')/\1?v=$BUILD_ID\2/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add build ID comment for debugging
  echo "<!-- Build: $BUILD_ID - $(date) -->" >> build/web/index.html
  
  echo "✅ Cache busting applied with build ID: $BUILD_ID"
  
  # Deploy to Firebase
  firebase deploy --only hosting
  
  echo "🚀 Deployment complete!"
else
  echo "❌ Build failed or could not find index.html file"
  exit 1
fi
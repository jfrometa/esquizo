#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

# Build Flutter web app with enhanced options for optimization and security
flutter build web --release --pwa-strategy=offline-first --dart-define=Dart2jsOptimization=O4 --csp

# Add the reCAPTCHA script to the head section of index.html
if [ -f "build/web/index.html" ]; then
  # Insert the reCAPTCHA script right after the opening head tag
  sed -i.bak 's/<head>/<head>\n  <script src="https:\/\/www.google.com\/recaptcha\/enterprise.js?render=6Ld9Af4qAAAAAK8M8Mq0BgCI6CTOELhOgnoRhiaV"><\/script>/' build/web/index.html
  rm build/web/index.html.bak
  
  echo "✅ Added reCAPTCHA Enterprise script to index.html"
  
  # Add cache busting to main.dart.js (the most important file)
  # This appends a query param with the build ID to force cache invalidation
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

echo "🚀 Build completed successfully with reCAPTCHA integration and cache busting"
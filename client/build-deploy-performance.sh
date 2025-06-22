#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

echo "🚀 Building Flutter web with performance optimizations..."

# Build Flutter web app with performance-focused settings
flutter build web \
  --release \
  --pwa-strategy=offline-first \
  -O4 \
  --csp \
  --source-maps \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=false

# Add the reCAPTCHA script to the head section of index.html
if [ -f "build/web/index.html" ]; then
  # Insert the reCAPTCHA script right after the opening head tag
  sed -i.bak 's/<head>/<head>\n  <script src="https:\/\/www.google.com\/recaptcha\/enterprise.js?render=6Ld9Af4qAAAAAK8M8Mq0BgCI6CTOELhOgnoRhiaV"><\/script>/' build/web/index.html
  rm build/web/index.html.bak
  
  echo "✅ Added reCAPTCHA Enterprise script to index.html"
  
  # Add cache busting to main.dart.js
  sed -i.bak "s/main\.dart\.js/main.dart.js?v=$BUILD_ID/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add cache busting to all JS files
  sed -i.bak -E "s/([a-zA-Z0-9_]+\.js)(\"|')/\1?v=$BUILD_ID\2/g" build/web/index.html
  rm build/web/index.html.bak
  
  # Add performance optimizations to the built index.html
  sed -i.bak 's/<head>/<head>\n  <meta name="color-scheme" content="light dark">\n  <meta name="theme-color" content="#000000">/' build/web/index.html
  rm build/web/index.html.bak
  
  # Add build ID to the page for debugging purposes
  echo "<!-- Performance Build: $BUILD_ID - $(date) -->" >> build/web/index.html
  echo "✅ Cache busting and performance optimizations applied with build ID: $BUILD_ID"
else
  echo "❌ Could not find index.html file"
  exit 1
fi

echo "🎯 Performance-optimized build completed successfully"

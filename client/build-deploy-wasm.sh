#!/bin/bash

# Generate a build timestamp or version ID
BUILD_ID=$(date +%s)

echo "🔧 Building with WASM compilation (experimental)..."

# Build Flutter web app with WASM compilation for testing
flutter build web --release --wasm

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
  echo "<!-- WASM Build: $BUILD_ID - $(date) -->" >> build/web/index.html
  echo "✅ Cache busting applied with build ID: $BUILD_ID"
  
  echo "⚠️  WASM renderer is experimental. If you encounter issues, use build-deploy.sh instead."
else
  echo "❌ Could not find index.html file"
  exit 1
fi

echo "🚀 WASM build completed successfully"

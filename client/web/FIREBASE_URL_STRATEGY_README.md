# Flutter Web URL Path Strategy with Firebase Hosting

This application uses Flutter's Path URL Strategy for clean, user-friendly URLs without hash fragments, deployed on Firebase Hosting.

## What's Implemented

- **Path URL Strategy**: The application uses `usePathUrlStrategy()` for clean URLs without hash fragments
- **Firebase Hosting**: Configured with proper URL rewriting rules in firebase.json
- **index.html**: Contains JavaScript to properly handle direct navigation to deep routes

## How It Works

1. The application calls `usePathUrlStrategy()` in main.dart to enable path-based URLs
2. Firebase Hosting is configured to route all requests to index.html (via rewrites in firebase.json)
3. JavaScript code in index.html ensures proper handling of direct navigation to deep links

## Firebase Hosting Configuration

The `firebase.json` file includes the following key settings:

```json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

This configuration ensures that all paths are directed to the index.html file, allowing Flutter to handle the routing.

## Testing Direct Navigation

To test if the path URL strategy is working correctly:

1. Deploy the application to Firebase Hosting: `firebase deploy --only hosting`
2. Navigate to a deep route like `https://your-firebase-app.web.app/some/nested/route`
3. Refresh the page - it should load correctly without errors

## Development Testing

When testing locally with `flutter run -d chrome`, the path URL strategy should work automatically as Flutter's built-in dev server handles the routing.

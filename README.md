## Getting Started

This project contains a Flutter application for the frontend, located in the `esquizo/client` directory, and a Dart backend in the `esquizo/db` directory.

### Prerequisites

- Flutter SDK: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- Dart SDK: (Included with Flutter)
- An IDE with Flutter support (VS Code, Android Studio, IntelliJ)

### Running the Flutter App

1.  Navigate to the `esquizo/client` directory:
```
bash
    cd esquizo/client
    
```
2.  Install dependencies:
```
bash
    flutter pub get
    
```
3.  Run the app:
```
bash
    flutter run
    
```
This will launch the app on a connected device or emulator.

### Running the Dart Backend

1.  Navigate to the `esquizo/db` directory:
```
bash
    cd esquizo/db
    
```
2.  Install dependencies:
```
bash
    dart pub get
    
```
3.  Run the backend:
```
bash
    dart run
    
```
This will start the backend server.  You may need to configure environment variables or other settings as required by your backend code.  Refer to the backend's specific documentation for details.

### Additional Notes

-   Make sure to have both the Flutter app and Dart backend running concurrently for full functionality.
-   Refer to the individual `README.md` files within the `client` and `db` directories for more specific instructions or configuration details related to each part of the project.
# Factory Tracking App

A Flutter mobile application for factory tracking with QR code scanning and stop card management.

## Features

- **QR Code Scanning**: Scan QR codes at checkpoints
- **Stop Card Management**: Create and manage stop cards with images
- **User Authentication**: Secure login and registration
- **Image Capture**: Take photos or select from gallery
- **Offline Support**: Local storage for tokens and data

## Project Structure

```
factory_tracking_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── services/              # API services and business logic
│   ├── screens/               # UI screens/pages
│   ├── widgets/               # Reusable UI components
│   └── utils/                 # Utility functions and constants
├── android/                   # Android-specific configuration
├── ios/                       # iOS-specific configuration
└── pubspec.yaml              # Dependencies and project configuration
```

## Dependencies

- **http**: HTTP client for API calls
- **provider**: State management
- **shared_preferences**: Local storage for tokens
- **qr_code_scanner**: QR code scanning functionality
- **image_picker**: Camera and gallery access
- **permission_handler**: Runtime permissions

## Permissions

### Android
- Camera access for QR scanning and image capture
- Internet access for API calls
- Storage access for image picker

### iOS
- Camera usage description
- Photo library usage description
- Network access configuration

## Getting Started

1. **Install Flutter**: Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install)

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## API Integration

The app is designed to work with the Factory Tracking API running on `http://localhost:5000`. Make sure the API server is running before using the mobile app.

### API Endpoints Used
- `POST /api/Auth/login` - User authentication
- `GET /api/StopCards` - Fetch stop cards
- `POST /api/CheckPoints/{id}/scan` - Scan checkpoint
- `POST /api/Image/upload` - Upload images

## Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep widgets small and focused

### State Management
- Use Provider for state management
- Separate business logic from UI components
- Use services for API calls

### Testing
- Write unit tests for services and utilities
- Write widget tests for UI components
- Test on both Android and iOS devices

## Build and Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

- **Permission Issues**: Make sure all required permissions are granted
- **API Connection**: Verify the API server is running and accessible
- **Camera Issues**: Test on physical devices (camera doesn't work on simulators)
- **Build Issues**: Run `flutter clean` and `flutter pub get`
# Lifeline Blood Donation App

A comprehensive Flutter application for managing blood donations, inventory, emergency requests, and connecting donors with hospitals and blood banks.

## Features

- **User Management**: Donor, Hospital, and Organization registration and profiles
- **Blood Donation Management**: Schedule and track blood donations
- **Emergency Requests**: Create and respond to urgent blood requests
- **Inventory Management**: Track blood inventory levels across hospitals
- **Analytics Dashboard**: Comprehensive analytics for donations, inventory, and user engagement
- **Notifications**: Real-time notifications for emergency requests and updates
- **Feedback System**: User feedback and rating system
- **Blood Drive Management**: Organize and participate in blood drives

## Prerequisites

Before running this application, ensure you have the following installed:

- **Flutter SDK** (3.16.0 or later): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (3.2.0 or later): Comes with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**: [Install Git](https://git-scm.com/downloads)

### Development Environment Setup

1. **Install Flutter**:
   ```bash
   # On Windows (using winget)
   winget install Flutter.Flutter

   # On macOS (using Homebrew)
   brew install flutter

   # On Linux
   sudo snap install flutter --classic
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```

3. **Install VS Code Extensions** (if using VS Code):
   - Flutter
   - Dart
   - Firebase

## Firebase Setup (Free Tier)

This app uses Firebase services which offer generous free tiers:

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `lifeline-blood-donation`
4. Accept Firebase terms and create project

### 2. Enable Firebase Services

Enable the following services in your Firebase project:

#### Authentication
1. Go to Authentication > Sign-in method
2. Enable Email/Password
3. Enable Google Sign-in (optional)

#### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in test mode (for development)
4. Choose location closest to your users

#### Firebase Analytics
1. Automatically enabled with project creation
2. No additional setup required

#### Firebase Messaging (for notifications)
1. Go to Cloud Messaging
2. No additional setup required for basic messaging

### 3. Configure Flutter App

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configure Firebase for Flutter**:
   ```bash
   cd lifeline_blood_donation_app
   flutterfire configure
   ```

5. **Select your Firebase project** when prompted

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# Google Maps API (for location features)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Other Configuration
APP_ENVIRONMENT=development
DEBUG_MODE=true
```

### Getting Google Maps API Key (Free)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Maps SDK for Android/iOS
4. Create credentials > API Key
5. Restrict the API key to your app's package name

## Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/lifeline-blood-donation-app.git
   cd lifeline-blood-donation-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (if not done already):
   ```bash
   flutterfire configure
   ```

4. **Create `.env` file** with your configuration (see Environment Variables section)

5. **Run the app**:
   ```bash
   # For debug mode
   flutter run

   # For specific device
   flutter devices
   flutter run -d <device_id>

   # For web (if enabled)
   flutter run -d chrome
   ```

## Building the App

### Debug Build
```bash
flutter run --debug
```

### Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── analytics.dart
│   ├── blood_inventory.dart
│   ├── donor.dart
│   ├── emergency_request.dart
│   └── feedback.dart
├── screens/                  # UI screens
│   ├── analytics/
│   ├── dashboard/
│   ├── emergency/
│   ├── feedback/
│   └── profile/
├── services/                 # Business logic and API calls
│   ├── analytics_service.dart
│   ├── auth_service.dart
│   ├── donor_service.dart
│   └── notification_service.dart
├── widgets/                  # Reusable UI components
└── utils/                   # Utility functions and constants
```

## Key Features Overview

### Analytics Dashboard
- **Donation Analytics**: Track donations by blood group, location, and time
- **Inventory Analytics**: Monitor blood stock levels and critical alerts
- **Emergency Statistics**: View emergency request fulfillment rates
- **User Engagement**: Track feedback and user interactions

### Free Tier Limitations and Alternatives

#### Firebase Free Tier Limits:
- **Firestore**: 50,000 reads, 20,000 writes, 20,000 deletes per day
- **Authentication**: Unlimited users
- **Cloud Messaging**: Unlimited notifications
- **Analytics**: Unlimited events

#### Alternative Free Services:
- **Supabase**: Alternative to Firebase with PostgreSQL
- **MongoDB Atlas**: Free 512MB cluster
- **PlanetScale**: Free MySQL database
- **Railway**: Free hosting with limitations

## Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Format code using `flutter format`

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Performance
- Use `const` constructors where possible
- Implement proper state management
- Optimize list views with `ListView.builder`
- Profile app performance with Flutter Inspector

## Troubleshooting

### Common Issues

1. **Firebase Configuration Error**:
   ```bash
   # Reconfigure Firebase
   flutterfire configure
   ```

2. **Dependency Conflicts**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build Errors**:
   ```bash
   flutter clean
   flutter pub deps
   flutter run
   ```

4. **Google Sign-In Issues**:
   - Ensure SHA-1 fingerprint is added to Firebase project
   - Check package name matches Firebase configuration

### Getting Help

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Community](https://flutter.dev/community)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation and troubleshooting guides

## Deployment

### Android Play Store
1. Build release APK/Bundle
2. Sign with release keystore
3. Upload to Play Console
4. Complete store listing and publish

### iOS App Store
1. Build for iOS release
2. Archive in Xcode
3. Upload to App Store Connect
4. Submit for review

### Web Deployment
```bash
flutter build web
# Deploy build/web folder to hosting service
```

## Monitoring and Analytics

The app includes comprehensive analytics tracking:
- User engagement metrics
- Donation tracking
- Emergency request analytics
- Inventory management insights
- Performance monitoring

All analytics are handled through Firebase Analytics with no additional cost.
   - Create a `.env` file in the root directory
   - Add your Firebase configuration:
     ```
     FIREBASE_API_KEY=your_api_key
     FIREBASE_APP_ID=your_app_id
     FIREBASE_MESSAGING_SENDER_ID=your_sender_id
     FIREBASE_PROJECT_ID=your_project_id
     ```

5. **Update Dependencies**
   - Check `pubspec.yaml` for required packages
   - Run `flutter pub get` to install dependencies

## 📱 Running the App

### Development Mode

1. **Start an Emulator/Device**
   - Android: Start Android emulator or connect physical device
   - iOS: Start iOS simulator or connect physical device

2. **Run the App**
   ```bash
   flutter run
   ```

### Production Build

1. **Android APK**
   ```bash
   flutter build apk --release
   ```
   The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

2. **iOS IPA**
   ```bash
   flutter build ios --release
   ```
   Then open Xcode to archive and distribute the app

## 🔧 Configuration

### Firebase Rules

Update Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Android Configuration

1. Update `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       applicationId "com.yourdomain.lifeline"
       minSdkVersion 21
       targetSdkVersion 33
       versionCode 1
       versionName "1.0.0"
   }
   ```

2. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest ...>
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
       <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
       ...
   </manifest>
   ```

### iOS Configuration

1. Update `ios/Runner/Info.plist`:
   ```xml
   <dict>
       <key>NSLocationWhenInUseUsageDescription</key>
       <string>We need your location to find nearby blood donation centers</string>
       <key>NSLocationAlwaysUsageDescription</key>
       <string>We need your location to find nearby blood donation centers</string>
       ...
   </dict>
   ```

## 📦 Project Structure

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic and API calls
├── widgets/         # Reusable widgets
├── utils/           # Utility functions
└── main.dart        # App entry point
```

## 🧪 Testing

1. **Unit Tests**
   ```bash
   flutter test
   ```

2. **Integration Tests**
   ```bash
   flutter test integration_test
   ```

## 🔍 Debugging

1. **Flutter DevTools**
   ```bash
   flutter run --debug
   ```
   Then press 'D' to open DevTools

2. **Firebase Console**
   - Monitor app performance
   - View crash reports
   - Check analytics

## 📱 Supported Platforms

- Android (API level 21+)
- iOS (iOS 11.0+)
- Web (experimental)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

Common issues and solutions:

1. **Firebase Configuration**
   - Ensure all configuration files are in correct locations
   - Verify Firebase project settings match app configuration

2. **Build Issues**
   - Run `flutter clean`
   - Delete build folder
   - Run `flutter pub get`
   - Try building again

3. **Dependencies**
   - Check for version conflicts in `pubspec.yaml`
   - Update Flutter and dependencies to latest versions

4. **Location Services**
   - Ensure location permissions are granted
   - Check device location settings

## 📞 Support

For support, email support@lifeline.com or create an issue in the repository.

# Environment Setup Guide

## Prerequisites Installation

### 1. Flutter SDK Installation

#### Windows
```bash
# Using winget (Windows Package Manager)
winget install Flutter.Flutter

# Or download from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\development\flutter
# Add C:\development\flutter\bin to PATH
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download from https://docs.flutter.dev/get-started/install/macos
# Extract to ~/development/flutter
# Add ~/development/flutter/bin to PATH
```

#### Linux
```bash
# Using Snap
sudo snap install flutter --classic

# Or download from https://docs.flutter.dev/get-started/install/linux
# Extract to ~/development/flutter
# Add ~/development/flutter/bin to PATH
```

### 2. Verify Flutter Installation
```bash
flutter doctor
```

Fix any issues shown by flutter doctor before proceeding.

### 3. IDE Setup

#### VS Code (Recommended)
1. Install VS Code from https://code.visualstudio.com/
2. Install Flutter extension
3. Install Dart extension
4. Install Firebase extension

#### Android Studio
1. Download from https://developer.android.com/studio
2. Install Flutter plugin
3. Install Dart plugin

## Firebase Setup (FREE)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `lifeline-blood-donation`
4. Choose your country/region
5. Accept Firebase terms
6. Wait for project creation

### Step 2: Configure Firebase Services

#### Authentication Setup
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password**
5. (Optional) Enable **Google** sign-in

#### Firestore Database Setup
1. Go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose location closest to your users
5. Click **Done**

#### Firebase Analytics Setup
- Automatically enabled when you create the project
- No additional configuration needed

#### Cloud Messaging Setup
1. Go to **Cloud Messaging**
2. No initial setup required
3. Will be configured automatically when you add the app

### Step 3: Add Flutter App to Firebase

1. In Firebase Console, click **Add app** and select **Flutter**
2. Register app:
   - **App nickname**: `Lifeline Blood Donation App`
   - **App ID**: `com.lifeline.blooddonation`
3. Click **Register app**

### Step 4: Install Firebase CLI Tools

```bash
# Install Node.js first (https://nodejs.org/)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Step 5: Configure Firebase in Flutter

```bash
# Navigate to your Flutter project
cd lifeline_blood_donation_app

# Configure Firebase
flutterfire configure

# Select your Firebase project when prompted
# Choose platforms (Android, iOS, Web, etc.)
```

This will create `firebase_options.dart` file automatically.

## Environment Variables Setup

### Create .env File

Create a `.env` file in the root directory of your Flutter project:

```env
# Firebase Configuration (get these from Firebase Console > Project Settings)
FIREBASE_API_KEY=AIzaSyC...
FIREBASE_AUTH_DOMAIN=lifeline-blood-donation.firebaseapp.com
FIREBASE_PROJECT_ID=lifeline-blood-donation
FIREBASE_STORAGE_BUCKET=lifeline-blood-donation.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abc123

# Google Maps API (Optional - for location features)
GOOGLE_MAPS_API_KEY=AIzaSyB...

# App Configuration
APP_ENVIRONMENT=development
DEBUG_MODE=true
```

### Get Firebase Configuration Values

1. Go to Firebase Console
2. Click on Project Settings (gear icon)
3. Scroll down to "Your apps" section
4. Click on your Flutter app
5. Copy the configuration values

### Get Google Maps API Key (Optional)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Maps SDK for Android** and **Maps SDK for iOS**
4. Go to **Credentials**
5. Click **Create Credentials** > **API Key**
6. Restrict the API key to your app's package name

## Dependencies Installation

### Install Flutter Dependencies

```bash
# Navigate to project directory
cd lifeline_blood_donation_app

# Get dependencies
flutter pub get
```

### Update pubspec.yaml (if needed)

Ensure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_analytics: ^10.7.4
  firebase_messaging: ^14.7.10
  
  # UI Components
  fl_chart: ^0.66.0
  
  # Utilities
  intl: ^0.19.0
  provider: ^6.1.1
  
  # Environment variables
  flutter_dotenv: ^5.1.0
```

## Running the Application

### 1. Start an Emulator/Device

#### Android
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Or connect a physical Android device with USB debugging enabled
```

#### iOS (macOS only)
```bash
# Open iOS Simulator
open -a Simulator

# Or connect a physical iOS device
```

### 2. Run the App

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>

# Run in release mode
flutter run --release
```

## Database Setup (Firestore)

### Firestore Security Rules

In Firebase Console, go to Firestore Database > Rules and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow all authenticated users to read donations data
    match /donations/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.donorId;
    }
    
    // Allow all authenticated users to read/write emergency requests
    match /emergency_requests/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Allow hospital staff to manage inventory
    match /blood_inventory/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'hospital';
    }
    
    // Allow authenticated users to submit feedback
    match /feedback/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Initialize Database Collections

The app will automatically create collections when data is first added. Initial collections include:

- `users` - User profiles (donors, hospitals, organizations)
- `donations` - Blood donation records
- `emergency_requests` - Emergency blood requests
- `blood_inventory` - Hospital blood inventory
- `feedback` - User feedback and ratings
- `blood_drives` - Blood drive events
- `notifications` - User notifications

## Testing the Setup

### 1. Verify Firebase Connection

```bash
# Run the app and check logs for Firebase initialization
flutter run --verbose
```

Look for messages like:
- "Firebase has been initialized"
- "FirebaseApp named '[DEFAULT]' already exists"

### 2. Test Authentication

1. Run the app
2. Try to register a new user
3. Check Firebase Console > Authentication > Users
4. Verify new user appears in the list

### 3. Test Database Operations

1. Complete user registration
2. Try to create a profile
3. Check Firebase Console > Firestore Database
4. Verify documents are created

## Troubleshooting

### Common Issues

#### 1. "Firebase project not found"
```bash
# Reconfigure Firebase
flutterfire configure
```

#### 2. "MultiDex required"
Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### 3. "Cleartext HTTP traffic not permitted"
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true">
```

#### 4. iOS Build Issues
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

#### 5. Dependency Conflicts
```bash
flutter clean
flutter pub deps
flutter pub get
```

### Getting Help

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter+firebase)

## Free Tier Limitations

### Firebase Free Plan (Spark Plan)

- **Firestore**: 50k reads, 20k writes, 20k deletes per day
- **Authentication**: Unlimited users
- **Cloud Functions**: 2M invocations/month
- **Cloud Messaging**: Unlimited messages
- **Analytics**: Unlimited events
- **Hosting**: 10GB storage, 1GB transfer/month

### Monitoring Usage

1. Go to Firebase Console
2. Check **Usage** tab for each service
3. Set up **Budget alerts** in Google Cloud Console
4. Monitor daily usage to stay within limits

### Alternative Free Services

If you exceed Firebase limits:

- **Supabase**: PostgreSQL-based Firebase alternative
- **Appwrite**: Open-source backend server
- **AWS Amplify**: AWS free tier
- **MongoDB Atlas**: 512MB free cluster

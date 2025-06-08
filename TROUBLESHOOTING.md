# Troubleshooting Guide

## Common Issues and Solutions

### 1. Flutter Installation Issues

#### Issue: "flutter: The term 'flutter' is not recognized"
**Solution:**
```powershell
# Check if Flutter is in PATH
$env:PATH -split ';' | Where-Object { $_ -like "*flutter*" }

# If not found, add Flutter to PATH
# For current session:
$env:PATH += ";C:\development\flutter\bin"

# Permanently (requires admin):
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\development\flutter\bin", "Machine")
```

#### Issue: Flutter Doctor shows issues
**Solution:**
```powershell
# Run Flutter Doctor for detailed diagnostics
flutter doctor -v

# Common fixes:
# Accept Android licenses
flutter doctor --android-licenses

# Install Visual Studio (for Windows development)
# Download from: https://visualstudio.microsoft.com/

# Install Android Studio
# Download from: https://developer.android.com/studio
```

### 2. Firebase Configuration Issues

#### Issue: "Firebase project not found"
**Solution:**
```powershell
# Reconfigure Firebase
flutterfire configure

# If FlutterFire CLI not installed:
dart pub global activate flutterfire_cli

# Add to PATH if needed:
$env:PATH += ";$env:APPDATA\Pub\Cache\bin"
```

#### Issue: "google-services.json not found"
**Solution:**
1. Go to Firebase Console
2. Select your project
3. Click on Android app
4. Download `google-services.json`
5. Place in `android/app/` directory

#### Issue: "GoogleService-Info.plist not found" (iOS)
**Solution:**
1. Go to Firebase Console
2. Select your project
3. Click on iOS app
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/` directory

### 3. Dependency Issues

#### Issue: "Package dependencies conflict"
**Solution:**
```powershell
# Clean and reinstall dependencies
flutter clean
flutter pub get

# If issues persist, delete pubspec.lock
Remove-Item pubspec.lock -ErrorAction SilentlyContinue
flutter pub get

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

#### Issue: "Version conflicts with intl package"
**Solution:**
Update `pubspec.yaml`:
```yaml
dependencies:
  intl: ^0.19.0  # Use latest stable version
```

Then run:
```powershell
flutter pub get
```

### 4. Build Issues

#### Issue: "Gradle build failed" (Android)
**Solution:**
```powershell
# Clean Gradle cache
cd android
.\gradlew clean
cd ..

# Clear Flutter build
flutter clean
flutter pub get

# If still failing, check Gradle version in android/gradle/wrapper/gradle-wrapper.properties
# Update to latest stable version
```

#### Issue: "MultiDex issue"
**Solution:**
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

#### Issue: "iOS build failed"
**Solution:**
```bash
# Navigate to iOS directory
cd ios

# Install/update CocoaPods
pod install --repo-update

# Clean and rebuild
cd ..
flutter clean
flutter build ios
```

### 5. Runtime Issues

#### Issue: "Firebase initialization failed"
**Solution:**
1. Check `firebase_options.dart` exists
2. Verify Firebase configuration in `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

#### Issue: "Location permissions denied"
**Solution:**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

For iOS, add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby blood donation centers</string>
```

#### Issue: "Network security error"
**Solution:**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
```

Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

### 6. Analytics Dashboard Issues

#### Issue: "Charts not displaying"
**Solution:**
1. Check `fl_chart` dependency in `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.66.0
```

2. Verify data is not null before rendering:
```dart
if (_analyticsData != null && _analyticsData!['donationStats'] != null) {
  // Render charts
}
```

#### Issue: "Analytics data not loading"
**Solution:**
1. Check Firestore security rules
2. Verify user authentication
3. Check network connectivity
4. Review service implementation

### 7. Authentication Issues

#### Issue: "Google Sign-In not working"
**Solution:**
1. Add SHA-1 fingerprint to Firebase project:
```powershell
# Debug fingerprint
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Add to Firebase Console > Project Settings > Your apps > Android app

#### Issue: "Email verification not sent"
**Solution:**
1. Check Firebase Authentication settings
2. Verify email templates in Firebase Console
3. Check spam folder
4. Ensure valid email address

### 8. Performance Issues

#### Issue: "App running slowly"
**Solution:**
1. Enable Flutter performance overlay:
```dart
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

2. Use `const` constructors:
```dart
const Text('Hello World')
const SizedBox(height: 16)
```

3. Optimize list rendering:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

#### Issue: "Memory leaks"
**Solution:**
1. Cancel stream subscriptions:
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

2. Dispose controllers:
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 9. Testing Issues

#### Issue: "Tests failing"
**Solution:**
1. Update test dependencies:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

2. Run tests with verbose output:
```powershell
flutter test --verbose
```

#### Issue: "Firebase mocking in tests"
**Solution:**
Use `fake_cloud_firestore` for testing:
```yaml
dev_dependencies:
  fake_cloud_firestore: ^2.4.1+1
```

### 10. Environment Setup Issues

#### Issue: ".env file not loaded"
**Solution:**
1. Ensure `flutter_dotenv` dependency:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Add .env to pubspec.yaml:
```yaml
flutter:
  assets:
    - .env
```

3. Load in main.dart:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

## Getting Help

### Debug Information Collection

When reporting issues, include:

1. **Flutter Doctor Output:**
```powershell
flutter doctor -v
```

2. **Dependencies Info:**
```powershell
flutter pub deps
```

3. **Build Logs:**
```powershell
flutter run --verbose
```

4. **Platform Information:**
- OS Version
- Flutter Version
- Dart Version
- IDE/Editor

### Support Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

### Community Forums

- [Flutter Discord](https://discord.com/invite/N7Yshp4)
- [Reddit r/FlutterDev](https://www.reddit.com/r/FlutterDev/)
- [Flutter Community](https://flutter.dev/community)

### Professional Support

For production applications, consider:
- Firebase Support Plans
- Flutter Consulting Services
- Professional Development Teams

## Preventive Measures

### Regular Maintenance

1. **Update Dependencies Monthly:**
```powershell
flutter pub outdated
flutter pub upgrade
```

2. **Monitor Firebase Usage:**
- Check Firebase Console usage metrics
- Set up budget alerts
- Monitor quotas

3. **Code Quality:**
```powershell
flutter analyze
flutter format .
```

4. **Testing:**
```powershell
flutter test
flutter test --coverage
```

### Best Practices

1. **Version Control:**
- Commit frequently
- Use meaningful commit messages
- Tag releases

2. **Documentation:**
- Keep README updated
- Document API changes
- Maintain changelog

3. **Monitoring:**
- Use Firebase Analytics
- Monitor crash reports
- Track performance metrics

4. **Security:**
- Regular security audits
- Update dependencies
- Review permissions

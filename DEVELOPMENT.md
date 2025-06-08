# Development Guide

## Project Architecture

### Overview
The Lifeline Blood Donation App follows a clean architecture pattern with clear separation of concerns:

- **Models**: Data structures and business entities
- **Services**: Business logic and API interactions
- **Screens**: UI components and user interfaces
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and constants

### Directory Structure

```
lib/
├── main.dart                     # App entry point
├── models/                       # Data models
│   ├── analytics.dart           # Analytics data structures
│   ├── blood_inventory.dart     # Inventory management models
│   ├── donor.dart               # Donor profile model
│   ├── emergency_request.dart   # Emergency request model
│   ├── feedback.dart            # Feedback and rating model
│   ├── notification.dart        # Notification model
│   └── user.dart                # Base user model
├── screens/                      # UI screens
│   ├── analytics/               # Analytics dashboard
│   ├── auth/                    # Authentication screens
│   ├── dashboard/               # User dashboards
│   ├── emergency/               # Emergency request screens
│   ├── feedback/                # Feedback management
│   ├── inventory/               # Inventory management
│   ├── notifications/           # Notification screens
│   └── profile/                 # User profile screens
├── services/                     # Business logic
│   ├── analytics_service.dart   # Analytics operations
│   ├── auth_service.dart        # Authentication
│   ├── donor_service.dart       # Donor management
│   ├── emergency_service.dart   # Emergency requests
│   ├── feedback_service.dart    # Feedback handling
│   ├── inventory_service.dart   # Inventory management
│   └── notification_service.dart # Push notifications
├── widgets/                      # Reusable components
│   ├── common/                  # Common UI widgets
│   ├── charts/                  # Chart components
│   └── forms/                   # Form components
└── utils/                       # Utilities
    ├── constants.dart           # App constants
    ├── helpers.dart             # Helper functions
    └── validators.dart          # Form validators
```

## Key Components

### 1. Analytics Dashboard

#### Features
- Real-time donation statistics
- Blood inventory tracking
- Emergency request analytics
- User engagement metrics
- Interactive charts and graphs

#### Implementation
- Uses `fl_chart` package for visualizations
- Real-time data from Firestore
- Responsive design for all screen sizes
- Export functionality for reports

#### Key Files
- `lib/screens/analytics/analytics_dashboard_screen.dart`
- `lib/services/analytics_service.dart`
- `lib/models/analytics.dart`

### 2. Authentication System

#### Features
- Email/password authentication
- Google Sign-in integration
- Role-based access control
- Password reset functionality
- Account verification

#### User Roles
- **Donor**: Individual blood donors
- **Hospital**: Medical institutions
- **Organization**: NGOs and blood banks
- **Admin**: System administrators

### 3. Emergency Request System

#### Features
- Create urgent blood requests
- Real-time notifications
- Location-based matching
- Request fulfillment tracking
- Priority handling

#### Workflow
1. Hospital creates emergency request
2. System notifies nearby donors
3. Donors respond to request
4. Hospital selects suitable donors
5. Donation appointment scheduled

### 4. Inventory Management

#### Features
- Real-time blood stock tracking
- Low stock alerts
- Blood type categorization
- Expiration date monitoring
- Transfer between hospitals

#### Blood Types Supported
- A+, A-, B+, B-, AB+, AB-, O+, O-
- Rh factor tracking
- Special blood types

## Development Standards

### Code Style Guidelines

#### Dart/Flutter Standards
```dart
// Use meaningful names
class DonationAnalytics {
  final int totalDonations;
  final Map<String, int> donationsByBloodGroup;
  
  // Constructor with named parameters
  const DonationAnalytics({
    required this.totalDonations,
    required this.donationsByBloodGroup,
  });
}

// Use const constructors where possible
const Widget loadingWidget = CircularProgressIndicator();

// Prefer final for immutable variables
final DateTime now = DateTime.now();

// Use meaningful function names
Future<List<Donor>> getEligibleDonors() async {
  // Implementation
}
```

#### File Naming
- Use snake_case for file names: `analytics_dashboard_screen.dart`
- Use PascalCase for class names: `AnalyticsDashboardScreen`
- Use camelCase for variables and functions: `totalDonations`

#### Import Organization
```dart
// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

// Local imports
import '../models/analytics.dart';
import '../services/analytics_service.dart';
```

### State Management

#### Using Provider Pattern
```dart
// Provider setup
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = false;

  Map<String, dynamic>? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _analyticsData = await _analyticsService.getComprehensiveReport();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Widget usage
class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        if (analyticsProvider.isLoading) {
          return const CircularProgressIndicator();
        }
        
        return AnalyticsContent(data: analyticsProvider.analyticsData);
      },
    );
  }
}
```

### Error Handling

#### Service Layer Error Handling
```dart
class AnalyticsService {
  Future<DonationAnalytics> generateDonationAnalytics() async {
    try {
      final donations = await _firestore.collection('donations').get();
      return _processDonationData(donations);
    } on FirebaseException catch (e) {
      throw AnalyticsException('Failed to fetch donations: ${e.message}');
    } catch (e) {
      throw AnalyticsException('Unexpected error: $e');
    }
  }
}

// Custom exceptions
class AnalyticsException implements Exception {
  final String message;
  const AnalyticsException(this.message);
  
  @override
  String toString() => 'AnalyticsException: $message';
}
```

#### UI Error Handling
```dart
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Testing Strategy

#### Unit Tests
```dart
// test/services/analytics_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline_blood_donation_app/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should generate donation analytics', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      // Act
      final result = await analyticsService.generateDonationAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result, isA<DonationAnalytics>());
      expect(result.totalDonations, greaterThanOrEqualTo(0));
    });
  });
}
```

#### Widget Tests
```dart
// test/widgets/analytics_dashboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline_blood_donation_app/screens/analytics/analytics_dashboard_screen.dart';

void main() {
  testWidgets('Analytics dashboard displays loading indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalyticsDashboardScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Performance Optimization

#### Efficient List Rendering
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: donations.length,
  itemBuilder: (context, index) {
    final donation = donations[index];
    return DonationTile(donation: donation);
  },
);

// Use const constructors
const DonationTile({
  Key? key,
  required this.donation,
}) : super(key: key);
```

#### Image Optimization
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: donor.profileImageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);
```

#### Memory Management
```dart
class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late StreamSubscription _analyticsSubscription;

  @override
  void initState() {
    super.initState();
    _analyticsSubscription = _analyticsService.analyticsStream.listen(
      (data) => setState(() => _analyticsData = data),
    );
  }

  @override
  void dispose() {
    _analyticsSubscription.cancel();
    super.dispose();
  }
}
```

## API Integration

### Firebase Integration

#### Firestore Operations
```dart
class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create operation
  Future<Donor> createDonor(Donor donor) async {
    final docRef = await _firestore.collection('donors').add(donor.toFirestore());
    final doc = await docRef.get();
    return Donor.fromFirestore(doc);
  }

  // Read operation
  Stream<List<Donor>> getDonors() {
    return _firestore
        .collection('donors')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Donor.fromFirestore(doc))
            .toList());
  }

  // Update operation
  Future<void> updateDonor(String id, Map<String, dynamic> data) async {
    await _firestore.collection('donors').doc(id).update(data);
  }

  // Delete operation
  Future<void> deleteDonor(String id) async {
    await _firestore.collection('donors').doc(id).delete();
  }
}
```

#### Authentication Integration
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

## Deployment

### Build Configuration

#### Android Build
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.lifeline.blooddonation"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### iOS Build
```yaml
# ios/Runner/Info.plist
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby blood donation centers</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

### Release Process

1. **Update version numbers**
2. **Run tests**
3. **Build release artifacts**
4. **Code signing**
5. **Upload to stores**

## Contributing

### Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass: `flutter test`
6. Run code analysis: `flutter analyze`
7. Format code: `flutter format .`
8. Commit your changes: `git commit -m "Add new feature"`
9. Push to your fork: `git push origin feature/new-feature`
10. Create a pull request

### Code Review Guidelines

- Code follows style guidelines
- All tests pass
- Documentation is updated
- Performance impact is considered
- Security implications are reviewed

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Tools
- [Flutter Inspector](https://docs.flutter.dev/development/tools/flutter-inspector)
- [Firebase Console](https://console.firebase.google.com/)
- [Android Studio](https://developer.android.com/studio)
- [VS Code](https://code.visualstudio.com/)

### Packages Used
- `firebase_core`: Firebase SDK core
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_analytics`: Analytics
- `firebase_messaging`: Push notifications
- `fl_chart`: Charts and graphs
- `provider`: State management
- `intl`: Internationalization

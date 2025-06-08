# API Documentation

## Overview

The Lifeline Blood Donation App uses Firebase as the backend service, providing:
- Authentication via Firebase Auth
- Database via Cloud Firestore
- Real-time updates via Firestore listeners
- Push notifications via Firebase Cloud Messaging
- Analytics via Firebase Analytics

## Authentication API

### AuthService

#### Sign Up
```dart
Future<User?> signUp(String email, String password)
```
**Description**: Creates a new user account
**Parameters**:
- `email`: User's email address
- `password`: User's password (minimum 6 characters)

**Returns**: `User?` - Firebase user object or null
**Throws**: `AuthException` on failure

**Example**:
```dart
try {
  final user = await AuthService().signUp('user@example.com', 'password123');
  print('User created: ${user?.uid}');
} catch (e) {
  print('Error: $e');
}
```

#### Sign In
```dart
Future<User?> signIn(String email, String password)
```
**Description**: Authenticates existing user
**Parameters**:
- `email`: User's email address
- `password`: User's password

**Returns**: `User?` - Firebase user object or null
**Throws**: `AuthException` on failure

#### Sign Out
```dart
Future<void> signOut()
```
**Description**: Signs out current user

#### Get Current User
```dart
User? get currentUser
```
**Description**: Returns currently authenticated user

#### Auth State Stream
```dart
Stream<User?> get authStateChanges
```
**Description**: Stream of authentication state changes

## Donor API

### DonorService

#### Create Donor
```dart
Future<Donor> createDonor(Donor donor)
```
**Description**: Creates a new donor profile
**Parameters**:
- `donor`: Donor object with profile information

**Returns**: `Donor` - Created donor with generated ID
**Throws**: `DonorException` on failure

**Example**:
```dart
final donor = Donor(
  id: '',
  name: 'John Doe',
  email: 'john@example.com',
  bloodGroup: 'O+',
  phone: '+1234567890',
  dateOfBirth: DateTime(1990, 1, 1),
  isEligible: true,
);

final createdDonor = await DonorService().createDonor(donor);
```

#### Get Donor by ID
```dart
Future<Donor?> getDonorById(String id)
```
**Description**: Retrieves donor by ID
**Parameters**:
- `id`: Donor's unique identifier

**Returns**: `Donor?` - Donor object or null if not found

#### Get Donors Stream
```dart
Stream<List<Donor>> getDonors()
```
**Description**: Stream of all donors
**Returns**: `Stream<List<Donor>>` - Real-time list of donors

#### Update Donor
```dart
Future<void> updateDonor(String id, Map<String, dynamic> data)
```
**Description**: Updates donor information
**Parameters**:
- `id`: Donor's unique identifier
- `data`: Map of fields to update

#### Delete Donor
```dart
Future<void> deleteDonor(String id)
```
**Description**: Deletes donor profile
**Parameters**:
- `id`: Donor's unique identifier

#### Get Eligible Donors
```dart
Future<List<Donor>> getEligibleDonors({String? bloodGroup, String? location})
```
**Description**: Retrieves eligible donors with optional filters
**Parameters**:
- `bloodGroup`: Filter by blood group (optional)
- `location`: Filter by location (optional)

**Returns**: `List<Donor>` - List of eligible donors

## Emergency Request API

### EmergencyService

#### Create Emergency Request
```dart
Future<EmergencyRequest> createEmergencyRequest(EmergencyRequest request)
```
**Description**: Creates urgent blood request
**Parameters**:
- `request`: Emergency request object

**Returns**: `EmergencyRequest` - Created request with generated ID

**Example**:
```dart
final request = EmergencyRequest(
  id: '',
  hospitalId: 'hospital123',
  bloodGroup: 'A+',
  unitsRequired: 5,
  isUrgent: true,
  dueDate: DateTime.now().add(Duration(hours: 6)),
  status: RequestStatus.pending,
  location: GeoPoint(37.7749, -122.4194),
);

final created = await EmergencyService().createEmergencyRequest(request);
```

#### Get Emergency Requests
```dart
Stream<List<EmergencyRequest>> getEmergencyRequests({
  String? bloodGroup,
  RequestStatus? status,
  bool? isUrgent,
})
```
**Description**: Stream of emergency requests with optional filters
**Parameters**:
- `bloodGroup`: Filter by blood group (optional)
- `status`: Filter by status (optional)
- `isUrgent`: Filter by urgency (optional)

**Returns**: `Stream<List<EmergencyRequest>>` - Real-time list

#### Update Request Status
```dart
Future<void> updateRequestStatus(String id, RequestStatus status)
```
**Description**: Updates request status
**Parameters**:
- `id`: Request unique identifier
- `status`: New status (`pending`, `fulfilled`, `expired`)

#### Fulfill Request
```dart
Future<void> fulfillRequest(String requestId, String donorId)
```
**Description**: Marks request as fulfilled by donor
**Parameters**:
- `requestId`: Request unique identifier
- `donorId`: Donor who fulfilled the request

#### Get Nearby Requests
```dart
Future<List<EmergencyRequest>> getNearbyRequests(
  GeoPoint userLocation,
  double radiusKm
)
```
**Description**: Gets emergency requests within radius
**Parameters**:
- `userLocation`: User's current location
- `radiusKm`: Search radius in kilometers

**Returns**: `List<EmergencyRequest>` - Nearby requests

## Inventory API

### InventoryService

#### Create Inventory Entry
```dart
Future<BloodInventory> createInventory(BloodInventory inventory)
```
**Description**: Creates blood inventory entry
**Parameters**:
- `inventory`: Inventory object with blood stock information

**Returns**: `BloodInventory` - Created inventory with generated ID

#### Get Hospital Inventory
```dart
Stream<List<BloodInventory>> getHospitalInventory(String hospitalId)
```
**Description**: Stream of hospital's blood inventory
**Parameters**:
- `hospitalId`: Hospital unique identifier

**Returns**: `Stream<List<BloodInventory>>` - Real-time inventory

#### Update Stock Level
```dart
Future<void> updateStockLevel(String id, int newUnits)
```
**Description**: Updates blood stock units
**Parameters**:
- `id`: Inventory entry ID
- `newUnits`: New number of units

#### Get Low Stock Items
```dart
Future<List<BloodInventory>> getLowStockItems(String hospitalId)
```
**Description**: Gets inventory items below critical level
**Parameters**:
- `hospitalId`: Hospital unique identifier

**Returns**: `List<BloodInventory>` - Low stock items

#### Transfer Blood
```dart
Future<void> transferBlood(
  String fromHospitalId,
  String toHospitalId,
  String bloodGroup,
  int units
)
```
**Description**: Transfers blood between hospitals
**Parameters**:
- `fromHospitalId`: Source hospital ID
- `toHospitalId`: Destination hospital ID
- `bloodGroup`: Blood type to transfer
- `units`: Number of units to transfer

## Analytics API

### AnalyticsService

#### Generate Donation Analytics
```dart
Future<DonationAnalytics> generateDonationAnalytics({
  DateTime? startDate,
  DateTime? endDate,
  String? location,
})
```
**Description**: Generates comprehensive donation analytics
**Parameters**:
- `startDate`: Analysis start date (optional)
- `endDate`: Analysis end date (optional)
- `location`: Filter by location (optional)

**Returns**: `DonationAnalytics` - Analytics data

#### Generate Inventory Analytics
```dart
Future<InventoryAnalytics> generateInventoryAnalytics({
  DateTime? startDate,
  DateTime? endDate,
  String? location,
})
```
**Description**: Generates inventory analytics
**Parameters**:
- `startDate`: Analysis start date (optional)
- `endDate`: Analysis end date (optional)
- `location`: Filter by location (optional)

**Returns**: `InventoryAnalytics` - Inventory analytics

#### Get Comprehensive Report
```dart
Future<Map<String, dynamic>> getComprehensiveReport()
```
**Description**: Gets complete analytics report
**Returns**: `Map<String, dynamic>` - Comprehensive analytics data

#### Track Event
```dart
Future<void> logEvent({
  required String name,
  Map<String, dynamic>? parameters,
})
```
**Description**: Logs custom analytics event
**Parameters**:
- `name`: Event name
- `parameters`: Event parameters (optional)

## Feedback API

### FeedbackService

#### Submit Feedback
```dart
Future<Feedback> submitFeedback(Feedback feedback)
```
**Description**: Submits user feedback
**Parameters**:
- `feedback`: Feedback object with rating and comments

**Returns**: `Feedback` - Submitted feedback with generated ID

#### Get Feedback Stream
```dart
Stream<List<Feedback>> getFeedbackStream({
  FeedbackType? type,
  String? userId,
})
```
**Description**: Stream of feedback with optional filters
**Parameters**:
- `type`: Filter by feedback type (optional)
- `userId`: Filter by user ID (optional)

**Returns**: `Stream<List<Feedback>>` - Real-time feedback list

#### Respond to Feedback
```dart
Future<void> respondToFeedback(String feedbackId, String response)
```
**Description**: Responds to user feedback
**Parameters**:
- `feedbackId`: Feedback unique identifier
- `response`: Response message

#### Get Average Rating
```dart
Future<double> getAverageRating({FeedbackType? type})
```
**Description**: Calculates average rating
**Parameters**:
- `type`: Filter by feedback type (optional)

**Returns**: `double` - Average rating (0.0 to 5.0)

## Notification API

### NotificationService

#### Send Push Notification
```dart
Future<void> sendPushNotification({
  required String userId,
  required String title,
  required String message,
  Map<String, dynamic>? data,
})
```
**Description**: Sends push notification to user
**Parameters**:
- `userId`: Target user ID
- `title`: Notification title
- `message`: Notification message
- `data`: Additional data (optional)

#### Send Emergency Alert
```dart
Future<void> sendEmergencyAlert({
  required String bloodGroup,
  required String location,
  required String message,
})
```
**Description**: Sends emergency alert to eligible donors
**Parameters**:
- `bloodGroup`: Required blood type
- `location`: Emergency location
- `message`: Alert message

#### Get User Notifications
```dart
Stream<List<AppNotification>> getUserNotifications(String userId)
```
**Description**: Stream of user's notifications
**Parameters**:
- `userId`: User unique identifier

**Returns**: `Stream<List<AppNotification>>` - Real-time notifications

#### Mark as Read
```dart
Future<void> markAsRead(String notificationId)
```
**Description**: Marks notification as read
**Parameters**:
- `notificationId`: Notification unique identifier

## Data Models

### Donor Model
```dart
class Donor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final DateTime dateOfBirth;
  final bool isEligible;
  final GeoPoint? location;
  final Timestamp? lastDonationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### EmergencyRequest Model
```dart
class EmergencyRequest {
  final String id;
  final String hospitalId;
  final String bloodGroup;
  final int unitsRequired;
  final bool isUrgent;
  final DateTime dueDate;
  final RequestStatus status;
  final GeoPoint location;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### BloodInventory Model
```dart
class BloodInventory {
  final String id;
  final String hospitalId;
  final String bloodGroup;
  final int units;
  final int criticalLevel;
  final int optimalLevel;
  final DateTime expirationDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Analytics Models
```dart
class DonationAnalytics {
  final String id;
  final int totalDonations;
  final Map<String, int> donationsByBloodGroup;
  final Map<String, int> donationsByLocation;
  final Map<String, int> donationsByMonth;
  final double averageDonationFrequency;
  final int activeDonors;
  final int newDonors;
  final DateTime timestamp;
  final String? location;
}

class InventoryAnalytics {
  final String id;
  final Map<String, int> currentStock;
  final Map<String, int> criticalLevels;
  final Map<String, int> optimalLevels;
  final Map<String, int> monthlyUsage;
  final Map<String, int> monthlyRestock;
  final double averageStockLevel;
  final int totalHospitals;
  final DateTime timestamp;
  final String? location;
}
```

### Feedback Model
```dart
class Feedback {
  final String id;
  final String userId;
  final FeedbackType type;
  final int rating;
  final String comment;
  final String? response;
  final DateTime createdAt;
  final DateTime? respondedAt;
}

enum FeedbackType {
  general,
  donation,
  emergency,
  app,
  hospital,
}
```

## Error Handling

### Exception Types

#### AuthException
```dart
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}
```

#### DonorException
```dart
class DonorException implements Exception {
  final String message;
  const DonorException(this.message);
}
```

#### InventoryException
```dart
class InventoryException implements Exception {
  final String message;
  const InventoryException(this.message);
}
```

#### AnalyticsException
```dart
class AnalyticsException implements Exception {
  final String message;
  const AnalyticsException(this.message);
}
```

### Error Response Format
```dart
{
  "error": {
    "code": "auth/user-not-found",
    "message": "There is no user record corresponding to this identifier.",
    "details": "The user may have been deleted."
  }
}
```

## Rate Limits

### Firebase Quotas (Free Tier)
- **Firestore**: 50,000 reads, 20,000 writes, 20,000 deletes per day
- **Authentication**: Unlimited
- **Cloud Messaging**: Unlimited
- **Analytics**: Unlimited events

### API Rate Limits
- **Emergency Requests**: Max 10 per hour per user
- **Feedback Submission**: Max 5 per day per user
- **Analytics Queries**: Max 100 per hour per user

## Security

### Authentication Required
All API endpoints require valid Firebase authentication token except:
- Public emergency requests (read-only)
- App information endpoints

### Role-Based Access
- **Donors**: Can create/update their profile, respond to emergencies
- **Hospitals**: Can manage inventory, create emergency requests
- **Organizations**: Can view analytics, manage blood drives
- **Admins**: Full access to all features

### Data Validation
All input data is validated before processing:
- Email format validation
- Phone number format validation
- Blood group validation (A+, A-, B+, B-, AB+, AB-, O+, O-)
- Date range validation
- Required field validation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/analytics.dart';
import '../models/donor.dart';
import '../models/emergency_request.dart';
import '../models/feedback.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final String _collection = 'analytics';

  // Track user events
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Create analytics entry
  Future<Analytics> createAnalytics(Analytics analytics) async {
    final docRef =
        await _firestore.collection(_collection).add(analytics.toFirestore());
    final doc = await docRef.get();
    return Analytics.fromFirestore(doc);
  }

  // Get analytics by type and time range
  Stream<List<Analytics>> getAnalyticsByType(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? bloodGroup,
  }) {
    Query query =
        _firestore.collection(_collection).where('type', isEqualTo: type);

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    if (location != null) {
      query = query.where('location', isEqualTo: location);
    }
    if (bloodGroup != null) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Analytics.fromFirestore(doc)).toList());
  }

  // Generate donation analytics
  Future<DonationAnalytics> generateDonationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    final donations = await _firestore
        .collection('donations')
        .where('timestamp', isGreaterThanOrEqualTo: startDate ?? DateTime(2000))
        .where('timestamp', isLessThanOrEqualTo: endDate ?? DateTime.now())
        .get();

    final donors = await _firestore.collection('donors').get();

    final Map<String, int> donationsByBloodGroup = {};
    final Map<String, int> donationsByLocation = {};
    final Map<String, int> donationsByMonth = {};
    int totalDonations = 0;
    int activeDonors = 0;
    int newDonors = 0;

    for (var doc in donations.docs) {
      final data = doc.data();
      final bloodGroup = data['bloodGroup'] as String;
      final donationLocation = data['location'] as String;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final month = '${timestamp.year}-${timestamp.month}';

      donationsByBloodGroup[bloodGroup] =
          (donationsByBloodGroup[bloodGroup] ?? 0) + 1;
      donationsByLocation[donationLocation] =
          (donationsByLocation[donationLocation] ?? 0) + 1;
      donationsByMonth[month] = (donationsByMonth[month] ?? 0) + 1;
      totalDonations++;
    }

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (var doc in donors.docs) {
      final data = doc.data();
      final lastDonation = data['lastDonationDate'] as Timestamp?;
      final createdAt = (data['createdAt'] as Timestamp).toDate();

      if (lastDonation != null &&
          lastDonation.toDate().isAfter(thirtyDaysAgo)) {
        activeDonors++;
      }
      if (createdAt.isAfter(thirtyDaysAgo)) {
        newDonors++;
      }
    }

    final averageDonationFrequency =
        totalDonations / (activeDonors == 0 ? 1 : activeDonors);

    return DonationAnalytics(
      id: '',
      totalDonations: totalDonations,
      donationsByBloodGroup: donationsByBloodGroup,
      donationsByLocation: donationsByLocation,
      donationsByMonth: donationsByMonth,
      averageDonationFrequency: averageDonationFrequency,
      activeDonors: activeDonors,
      newDonors: newDonors,
      timestamp: DateTime.now(),
      location: location,
    );
  }

  // Generate inventory analytics
  Future<InventoryAnalytics> generateInventoryAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    final inventory = await _firestore
        .collection('blood_inventory')
        .where('isActive', isEqualTo: true)
        .get();

    final Map<String, int> currentStock = {};
    final Map<String, int> criticalLevels = {};
    final Map<String, int> optimalLevels = {};
    final Map<String, int> monthlyUsage = {};
    final Map<String, int> monthlyRestock = {};
    int totalHospitals = 0;
    double totalStockLevel = 0;

    for (var doc in inventory.docs) {
      final data = doc.data();
      final bloodGroup = data['bloodGroup'] as String;
      final units = data['units'] as int;
      final criticalLevel = data['criticalLevel'] as int;
      final optimalLevel = data['optimalLevel'] as int;

      currentStock[bloodGroup] = (currentStock[bloodGroup] ?? 0) + units;
      criticalLevels[bloodGroup] =
          (criticalLevels[bloodGroup] ?? 0) + criticalLevel;
      optimalLevels[bloodGroup] =
          (optimalLevels[bloodGroup] ?? 0) + optimalLevel;
      totalStockLevel += units / optimalLevel;
      totalHospitals++;
    }

    final averageStockLevel =
        totalStockLevel / (totalHospitals == 0 ? 1 : totalHospitals);

    return InventoryAnalytics(
      id: '',
      currentStock: currentStock,
      criticalLevels: criticalLevels,
      optimalLevels: optimalLevels,
      monthlyUsage: monthlyUsage,
      monthlyRestock: monthlyRestock,
      averageStockLevel: averageStockLevel,
      totalHospitals: totalHospitals,
      timestamp: DateTime.now(),
      location: location,
    );
  }

  // Get analytics for a specific hospital
  Stream<List<Analytics>> getHospitalAnalytics(String hospitalId) {
    return _firestore
        .collection(_collection)
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Analytics.fromFirestore(doc)).toList());
  }

  // Get analytics for a specific blood group
  Stream<List<Analytics>> getBloodGroupAnalytics(String bloodGroup) {
    return _firestore
        .collection(_collection)
        .where('bloodGroup', isEqualTo: bloodGroup)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Analytics.fromFirestore(doc)).toList());
  }

  // Get analytics for a specific location
  Stream<List<Analytics>> getLocationAnalytics(String location) {
    return _firestore
        .collection(_collection)
        .where('location', isEqualTo: location)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Analytics.fromFirestore(doc)).toList());
  }

  // Get analytics for a specific time period
  Stream<List<Analytics>> getTimePeriodAnalytics(
      DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(_collection)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Analytics.fromFirestore(doc)).toList());
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStats() async {
    final donorsSnapshot = await _firestore.collection('donors').get();
    final donors =
        donorsSnapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();

    final Map<String, int> bloodGroupCount = {};
    final Map<String, int> monthlyDonations = {};
    int totalDonations = 0;
    int eligibleDonors = 0;

    for (var donor in donors) {
      // Blood group distribution
      bloodGroupCount[donor.bloodGroup] =
          (bloodGroupCount[donor.bloodGroup] ?? 0) + 1;
      // Monthly donation trends
      if (donor.lastDonationDate != null) {
        final month = donor.lastDonationDate!.toString().substring(0, 7);
        monthlyDonations[month] = (monthlyDonations[month] ?? 0) + 1;
        totalDonations++;
      }

      // Eligible donors count
      if (donor.isEligible) {
        eligibleDonors++;
      }
    }

    return {
      'totalDonors': donors.length,
      'eligibleDonors': eligibleDonors,
      'totalDonations': totalDonations,
      'bloodGroupDistribution': bloodGroupCount,
      'monthlyDonations': monthlyDonations,
    };
  }

  // Get emergency request statistics
  Future<Map<String, dynamic>> getEmergencyStats() async {
    final requestsSnapshot =
        await _firestore.collection('emergency_requests').get();
    final requests = requestsSnapshot.docs
        .map((doc) => EmergencyRequest.fromFirestore(doc))
        .toList();

    final Map<String, int> bloodGroupRequests = {};
    final Map<String, int> statusCount = {};
    int totalRequests = requests.length;
    int fulfilledRequests = 0;
    int urgentRequests = 0;

    for (var request in requests) {
      // Blood group distribution
      bloodGroupRequests[request.bloodGroup] =
          (bloodGroupRequests[request.bloodGroup] ?? 0) + 1;

      // Status distribution
      statusCount[request.status] = (statusCount[request.status] ?? 0) + 1;

      // Count fulfilled and urgent requests
      if (request.isFulfilled) {
        fulfilledRequests++;
      }
      if (request.isUrgent) {
        urgentRequests++;
      }
    }

    return {
      'totalRequests': totalRequests,
      'fulfilledRequests': fulfilledRequests,
      'urgentRequests': urgentRequests,
      'bloodGroupRequests': bloodGroupRequests,
      'statusDistribution': statusCount,
    };
  }

  // Get user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementStats() async {
    final feedbackSnapshot = await _firestore.collection('feedback').get();
    final feedbacks = feedbackSnapshot.docs
        .map((doc) => Feedback.fromFirestore(doc))
        .toList();
    final Map<String, int> feedbackTypeCount = {};
    double averageRating = 0;
    int totalResponses = 0;

    for (var feedback in feedbacks) {
      final typeKey = feedback.type.toString().split('.').last;
      feedbackTypeCount[typeKey] = (feedbackTypeCount[typeKey] ?? 0) + 1;
      averageRating += feedback.rating;
      if (feedback.response != null) {
        totalResponses++;
      }
    }

    return {
      'totalFeedbacks': feedbacks.length,
      'feedbackTypeDistribution': feedbackTypeCount,
      'averageRating': feedbacks.isEmpty ? 0 : averageRating / feedbacks.length,
      'responseRate': feedbacks.isEmpty ? 0 : totalResponses / feedbacks.length,
    };
  }

  // Get location-based statistics
  Future<Map<String, dynamic>> getLocationStats() async {
    final donorsSnapshot = await _firestore.collection('donors').get();
    final donors =
        donorsSnapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();

    final Map<String, int> locationCount = {};
    int totalWithLocation = 0;

    for (var donor in donors) {
      if (donor.location != null) {
        final location = donor.location!;
        final locationKey = '${location.latitude},${location.longitude}';
        locationCount[locationKey] = (locationCount[locationKey] ?? 0) + 1;
        totalWithLocation++;
      }
    }

    return {
      'totalWithLocation': totalWithLocation,
      'locationDistribution': locationCount,
    };
  }

  // Get comprehensive analytics report
  Future<Map<String, dynamic>> getComprehensiveReport() async {
    final donationStats = await getDonationStats();
    final emergencyStats = await getEmergencyStats();
    final userEngagementStats = await getUserEngagementStats();
    final locationStats = await getLocationStats();

    return {
      'donationStats': donationStats,
      'emergencyStats': emergencyStats,
      'userEngagementStats': userEngagementStats,
      'locationStats': locationStats,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Track specific events
  Future<void> trackDonation({
    required String donorId,
    required String bloodGroup,
    required String location,
  }) async {
    await logEvent(
      name: 'blood_donation',
      parameters: {
        'donor_id': donorId,
        'blood_group': bloodGroup,
        'location': location,
      },
    );
  }

  Future<void> trackEmergencyRequest({
    required String requestId,
    required String bloodGroup,
    required bool isUrgent,
  }) async {
    await logEvent(
      name: 'emergency_request',
      parameters: {
        'request_id': requestId,
        'blood_group': bloodGroup,
        'is_urgent': isUrgent,
      },
    );
  }

  Future<void> trackUserFeedback({
    required String userId,
    required FeedbackType type,
    required int rating,
  }) async {
    await logEvent(
      name: 'user_feedback',
      parameters: {
        'user_id': userId,
        'feedback_type': type.toString(),
        'rating': rating,
      },
    );
  }
}

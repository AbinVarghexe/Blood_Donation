import 'package:cloud_firestore/cloud_firestore.dart';

class Analytics {
  final String id;
  final String type; // 'donation', 'request', 'inventory', 'user'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? location;
  final String? bloodGroup;
  final String? userId;
  final String? hospitalId;
  final Map<String, dynamic>? metadata;

  Analytics({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.location,
    this.bloodGroup,
    this.userId,
    this.hospitalId,
    this.metadata,
  });

  factory Analytics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Analytics(
      id: doc.id,
      type: data['type'] ?? '',
      data: data['data'] ?? {},
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'],
      bloodGroup: data['bloodGroup'],
      userId: data['userId'],
      hospitalId: data['hospitalId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'bloodGroup': bloodGroup,
      'userId': userId,
      'hospitalId': hospitalId,
      'metadata': metadata,
    };
  }

  Analytics copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? location,
    String? bloodGroup,
    String? userId,
    String? hospitalId,
    Map<String, dynamic>? metadata,
  }) {
    return Analytics(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      userId: userId ?? this.userId,
      hospitalId: hospitalId ?? this.hospitalId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class DonationAnalytics extends Analytics {
  final int totalDonations;
  final Map<String, int> donationsByBloodGroup;
  final Map<String, int> donationsByLocation;
  final Map<String, int> donationsByMonth;
  final double averageDonationFrequency;
  final int activeDonors;
  final int newDonors;

  DonationAnalytics({
    required super.id,
    required this.totalDonations,
    required this.donationsByBloodGroup,
    required this.donationsByLocation,
    required this.donationsByMonth,
    required this.averageDonationFrequency,
    required this.activeDonors,
    required this.newDonors,
    required super.timestamp,
    super.location,
    super.bloodGroup,
    super.userId,
    super.hospitalId,
    super.metadata,
  }) : super(
          type: 'donation',
          data: {
            'totalDonations': totalDonations,
            'donationsByBloodGroup': donationsByBloodGroup,
            'donationsByLocation': donationsByLocation,
            'donationsByMonth': donationsByMonth,
            'averageDonationFrequency': averageDonationFrequency,
            'activeDonors': activeDonors,
            'newDonors': newDonors,
          },
        );

  factory DonationAnalytics.fromAnalytics(Analytics analytics) {
    return DonationAnalytics(
      id: analytics.id,
      totalDonations: analytics.data['totalDonations'] ?? 0,
      donationsByBloodGroup:
          Map<String, int>.from(analytics.data['donationsByBloodGroup'] ?? {}),
      donationsByLocation:
          Map<String, int>.from(analytics.data['donationsByLocation'] ?? {}),
      donationsByMonth:
          Map<String, int>.from(analytics.data['donationsByMonth'] ?? {}),
      averageDonationFrequency:
          analytics.data['averageDonationFrequency'] ?? 0.0,
      activeDonors: analytics.data['activeDonors'] ?? 0,
      newDonors: analytics.data['newDonors'] ?? 0,
      timestamp: analytics.timestamp,
      location: analytics.location,
      bloodGroup: analytics.bloodGroup,
      userId: analytics.userId,
      hospitalId: analytics.hospitalId,
      metadata: analytics.metadata,
    );
  }
}

class InventoryAnalytics extends Analytics {
  final Map<String, int> currentStock;
  final Map<String, int> criticalLevels;
  final Map<String, int> optimalLevels;
  final Map<String, int> monthlyUsage;
  final Map<String, int> monthlyRestock;
  final double averageStockLevel;
  final int totalHospitals;

  InventoryAnalytics({
    required super.id,
    required this.currentStock,
    required this.criticalLevels,
    required this.optimalLevels,
    required this.monthlyUsage,
    required this.monthlyRestock,
    required this.averageStockLevel,
    required this.totalHospitals,
    required super.timestamp,
    super.location,
    super.bloodGroup,
    super.userId,
    super.hospitalId,
    super.metadata,
  }) : super(
          type: 'inventory',
          data: {
            'currentStock': currentStock,
            'criticalLevels': criticalLevels,
            'optimalLevels': optimalLevels,
            'monthlyUsage': monthlyUsage,
            'monthlyRestock': monthlyRestock,
            'averageStockLevel': averageStockLevel,
            'totalHospitals': totalHospitals,
          },
        );

  factory InventoryAnalytics.fromAnalytics(Analytics analytics) {
    return InventoryAnalytics(
      id: analytics.id,
      currentStock: Map<String, int>.from(analytics.data['currentStock'] ?? {}),
      criticalLevels:
          Map<String, int>.from(analytics.data['criticalLevels'] ?? {}),
      optimalLevels:
          Map<String, int>.from(analytics.data['optimalLevels'] ?? {}),
      monthlyUsage: Map<String, int>.from(analytics.data['monthlyUsage'] ?? {}),
      monthlyRestock:
          Map<String, int>.from(analytics.data['monthlyRestock'] ?? {}),
      averageStockLevel: analytics.data['averageStockLevel'] ?? 0.0,
      totalHospitals: analytics.data['totalHospitals'] ?? 0,
      timestamp: analytics.timestamp,
      location: analytics.location,
      bloodGroup: analytics.bloodGroup,
      userId: analytics.userId,
      hospitalId: analytics.hospitalId,
      metadata: analytics.metadata,
    );
  }
}

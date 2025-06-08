import 'package:cloud_firestore/cloud_firestore.dart';

class BloodInventory {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String bloodGroup;
  final int units;
  final int criticalLevel;
  final int optimalLevel;
  final DateTime lastUpdated;
  final String lastUpdatedBy;
  final Map<String, dynamic>? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BloodInventory({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.bloodGroup,
    required this.units,
    required this.criticalLevel,
    required this.optimalLevel,
    required this.lastUpdated,
    required this.lastUpdatedBy,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodInventory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BloodInventory(
      id: doc.id,
      hospitalId: data['hospitalId'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      units: data['units'] ?? 0,
      criticalLevel: data['criticalLevel'] ?? 5,
      optimalLevel: data['optimalLevel'] ?? 20,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'bloodGroup': bloodGroup,
      'units': units,
      'criticalLevel': criticalLevel,
      'optimalLevel': optimalLevel,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'lastUpdatedBy': lastUpdatedBy,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BloodInventory copyWith({
    String? id,
    String? hospitalId,
    String? hospitalName,
    String? bloodGroup,
    int? units,
    int? criticalLevel,
    int? optimalLevel,
    DateTime? lastUpdated,
    String? lastUpdatedBy,
    Map<String, dynamic>? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodInventory(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      units: units ?? this.units,
      criticalLevel: criticalLevel ?? this.criticalLevel,
      optimalLevel: optimalLevel ?? this.optimalLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCritical => units <= criticalLevel;
  bool get isOptimal => units >= optimalLevel;
  bool get needsRestock => units < optimalLevel;
  int get availableUnits => units;
  double get stockLevelPercentage => (units / optimalLevel) * 100;
} 
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequest {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String bloodGroup;
  final int units;
  final String reason;
  final String patientDetails;
  final GeoPoint location;
  final String address;
  final DateTime requiredBy;
  final String status; // 'active', 'fulfilled', 'expired', 'cancelled'
  final List<String> respondingDonors;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyRequest({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.bloodGroup,
    required this.units,
    required this.reason,
    required this.patientDetails,
    required this.location,
    required this.address,
    required this.requiredBy,
    this.status = 'active',
    this.respondingDonors = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyRequest(
      id: doc.id,
      hospitalId: data['hospitalId'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      units: data['units'] ?? 0,
      reason: data['reason'] ?? '',
      patientDetails: data['patientDetails'] ?? '',
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      requiredBy: (data['requiredBy'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      respondingDonors: List<String>.from(data['respondingDonors'] ?? []),
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
      'reason': reason,
      'patientDetails': patientDetails,
      'location': location,
      'address': address,
      'requiredBy': Timestamp.fromDate(requiredBy),
      'status': status,
      'respondingDonors': respondingDonors,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EmergencyRequest copyWith({
    String? id,
    String? hospitalId,
    String? hospitalName,
    String? bloodGroup,
    int? units,
    String? reason,
    String? patientDetails,
    GeoPoint? location,
    String? address,
    DateTime? requiredBy,
    String? status,
    List<String>? respondingDonors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      units: units ?? this.units,
      reason: reason ?? this.reason,
      patientDetails: patientDetails ?? this.patientDetails,
      location: location ?? this.location,
      address: address ?? this.address,
      requiredBy: requiredBy ?? this.requiredBy,
      status: status ?? this.status,
      respondingDonors: respondingDonors ?? this.respondingDonors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isFulfilled => status == 'fulfilled';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  bool get isUrgent {
    final hoursUntilRequired = requiredBy.difference(DateTime.now()).inHours;
    return hoursUntilRequired <= 24;
  }

  int get remainingUnits {
    return units - respondingDonors.length;
  }

  bool get isFullyResponded {
    return remainingUnits <= 0;
  }
} 
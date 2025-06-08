import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDrive {
  final String id;
  final String title;
  final String description;
  final String location;
  final GeoPoint coordinates;
  final DateTime startDate;
  final DateTime endDate;
  final String organizerId;
  final String organizerName;
  final List<String> targetBloodGroups;
  final int targetDonors;
  final int registeredDonors;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final List<String> registeredDonorIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BloodDrive({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.coordinates,
    required this.startDate,
    required this.endDate,
    required this.organizerId,
    required this.organizerName,
    required this.targetBloodGroups,
    required this.targetDonors,
    this.registeredDonors = 0,
    this.status = 'upcoming',
    this.registeredDonorIds = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory BloodDrive.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BloodDrive(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      coordinates: data['coordinates'] as GeoPoint,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      targetBloodGroups: List<String>.from(data['targetBloodGroups'] ?? []),
      targetDonors: data['targetDonors'] ?? 0,
      registeredDonors: data['registeredDonors'] ?? 0,
      status: data['status'] ?? 'upcoming',
      registeredDonorIds: List<String>.from(data['registeredDonorIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'coordinates': coordinates,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'organizerId': organizerId,
      'organizerName': organizerName,
      'targetBloodGroups': targetBloodGroups,
      'targetDonors': targetDonors,
      'registeredDonors': registeredDonors,
      'status': status,
      'registeredDonorIds': registeredDonorIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BloodDrive copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    GeoPoint? coordinates,
    DateTime? startDate,
    DateTime? endDate,
    String? organizerId,
    String? organizerName,
    List<String>? targetBloodGroups,
    int? targetDonors,
    int? registeredDonors,
    String? status,
    List<String>? registeredDonorIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodDrive(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      targetBloodGroups: targetBloodGroups ?? this.targetBloodGroups,
      targetDonors: targetDonors ?? this.targetDonors,
      registeredDonors: registeredDonors ?? this.registeredDonors,
      status: status ?? this.status,
      registeredDonorIds: registeredDonorIds ?? this.registeredDonorIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
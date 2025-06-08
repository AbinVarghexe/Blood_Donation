import 'package:cloud_firestore/cloud_firestore.dart';

class Donor {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String bloodGroup;
  final DateTime dateOfBirth;
  final String? address;
  final GeoPoint? location;
  final DateTime? lastDonationDate;
  final bool isEligible;
  final List<String> medicalConditions;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  Donor({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.bloodGroup,
    required this.dateOfBirth,
    this.address,
    this.location,
    this.lastDonationDate,
    this.isEligible = true,
    this.medicalConditions = const [],
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Donor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donor(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      bloodGroup: data['bloodGroup'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      address: data['address'],
      location: data['location'] as GeoPoint?,
      lastDonationDate: data['lastDonationDate'] != null
          ? (data['lastDonationDate'] as Timestamp).toDate()
          : null,
      isEligible: data['isEligible'] ?? true,
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      preferences: data['preferences'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'address': address,
      'location': location,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'isEligible': isEligible,
      'medicalConditions': medicalConditions,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Donor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? address,
    GeoPoint? location,
    DateTime? lastDonationDate,
    bool? isEligible,
    List<String>? medicalConditions,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Donor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      location: location ?? this.location,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isEligible: isEligible ?? this.isEligible,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canDonate {
    if (!isEligible) return false;
    if (lastDonationDate == null) return true;
    
    // Check if 56 days have passed since last donation
    final daysSinceLastDonation = DateTime.now().difference(lastDonationDate!).inDays;
    return daysSinceLastDonation >= 56;
  }

  int get daysUntilNextDonation {
    if (lastDonationDate == null) return 0;
    final daysSinceLastDonation = DateTime.now().difference(lastDonationDate!).inDays;
    return 56 - daysSinceLastDonation;
  }
} 
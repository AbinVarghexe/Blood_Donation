class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final String role; // 'donor', 'hospital', 'organization', 'admin'
  final String? bloodGroup;
  final DateTime? lastDonation;
  final Map<String, dynamic>? location;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    required this.role,
    this.bloodGroup,
    this.lastDonation,
    this.location,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      role: map['role'] ?? 'donor',
      bloodGroup: map['bloodGroup'],
      lastDonation: map['lastDonation'] != null 
          ? DateTime.parse(map['lastDonation']) 
          : null,
      location: map['location'],
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'bloodGroup': bloodGroup,
      'lastDonation': lastDonation?.toIso8601String(),
      'location': location,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    String? role,
    String? bloodGroup,
    DateTime? lastDonation,
    Map<String, dynamic>? location,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      lastDonation: lastDonation ?? this.lastDonation,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
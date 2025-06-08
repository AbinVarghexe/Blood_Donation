import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_drive.dart';

class BloodDriveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'blood_drives';

  // Create a new blood drive
  Future<BloodDrive> createBloodDrive(BloodDrive bloodDrive) async {
    final docRef =
        await _firestore.collection(_collection).add(bloodDrive.toFirestore());
    return bloodDrive.copyWith(id: docRef.id);
  }

  // Get a blood drive by ID
  Future<BloodDrive?> getBloodDrive(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return BloodDrive.fromFirestore(doc);
  }

  // Get a blood drive by ID as a stream for real-time updates
  Stream<BloodDrive?> getBloodDriveStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BloodDrive.fromFirestore(doc);
    });
  }

  // Update a blood drive
  Future<void> updateBloodDrive(BloodDrive bloodDrive) async {
    await _firestore
        .collection(_collection)
        .doc(bloodDrive.id)
        .update(bloodDrive.toFirestore());
  }

  // Delete a blood drive
  Future<void> deleteBloodDrive(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get all blood drives
  Stream<List<BloodDrive>> getAllBloodDrives() {
    return _firestore
        .collection(_collection)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BloodDrive.fromFirestore(doc)).toList());
  }

  // Get blood drives by organizer
  Stream<List<BloodDrive>> getBloodDrivesByOrganizer(String organizerId) {
    return _firestore
        .collection(_collection)
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BloodDrive.fromFirestore(doc)).toList());
  }

  // Get upcoming blood drives
  Stream<List<BloodDrive>> getUpcomingBloodDrives() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('startDate', isGreaterThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'upcoming')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BloodDrive.fromFirestore(doc)).toList());
  }

  // Register a donor for a blood drive
  Future<void> registerDonor(String bloodDriveId, String donorId) async {
    final docRef = _firestore.collection(_collection).doc(bloodDriveId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        throw Exception('Blood drive not found');
      }

      final bloodDrive = BloodDrive.fromFirestore(doc);
      if (bloodDrive.registeredDonorIds.contains(donorId)) {
        throw Exception('Donor already registered');
      }

      final updatedDonorIds = [...bloodDrive.registeredDonorIds, donorId];
      transaction.update(docRef, {
        'registeredDonorIds': updatedDonorIds,
        'registeredDonors': updatedDonorIds.length,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // Unregister a donor from a blood drive
  Future<void> unregisterDonor(String bloodDriveId, String donorId) async {
    final docRef = _firestore.collection(_collection).doc(bloodDriveId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        throw Exception('Blood drive not found');
      }

      final bloodDrive = BloodDrive.fromFirestore(doc);
      if (!bloodDrive.registeredDonorIds.contains(donorId)) {
        throw Exception('Donor not registered');
      }

      final updatedDonorIds =
          bloodDrive.registeredDonorIds.where((id) => id != donorId).toList();
      transaction.update(docRef, {
        'registeredDonorIds': updatedDonorIds,
        'registeredDonors': updatedDonorIds.length,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // Update blood drive status
  Future<void> updateStatus(String bloodDriveId, String status) async {
    await _firestore.collection(_collection).doc(bloodDriveId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  // Search blood drives by location
  Future<List<BloodDrive>> searchBloodDrivesByLocation(
      GeoPoint location, double radiusInKm) async {
    // TODO: Implement location-based search using GeoFirestore
    throw UnimplementedError('Location-based search not implemented yet');
  }
}

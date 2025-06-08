import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donor.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'donors';

  // Create a new donor profile
  Future<Donor> createDonor(Donor donor) async {
    final docRef =
        await _firestore.collection(_collection).add(donor.toFirestore());
    return donor.copyWith(id: docRef.id);
  }

  // Get a donor by ID
  Future<Donor?> getDonor(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Donor.fromFirestore(doc);
  }

  // Get a donor by ID as a stream for real-time updates
  Stream<Donor?> getDonorStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Donor.fromFirestore(doc);
    });
  }

  // Update a donor's profile
  Future<void> updateDonor(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a donor's profile
  Future<void> deleteDonor(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get all donors
  Stream<List<Donor>> getAllDonors() {
    return _firestore.collection(_collection).orderBy('name').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList());
  }

  // Get donors by blood group
  Stream<List<Donor>> getDonorsByBloodGroup(String bloodGroup) {
    return _firestore
        .collection(_collection)
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('isEligible', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList());
  }

  // Get eligible donors near a location
  Stream<List<Donor>> getEligibleDonorsNearby(
      GeoPoint location, double radiusInKm) {
    // TODO: Implement geospatial query using GeoFirestore
    // For now, return all eligible donors
    return _firestore
        .collection(_collection)
        .where('isEligible', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList());
  }

  // Update donor's last donation date
  Future<void> updateLastDonationDate(String id, DateTime date) async {
    await _firestore.collection(_collection).doc(id).update({
      'lastDonationDate': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update donor's eligibility
  Future<void> updateEligibility(String id, bool isEligible) async {
    await _firestore.collection(_collection).doc(id).update({
      'isEligible': isEligible,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add medical condition
  Future<void> addMedicalCondition(String id, String condition) async {
    await _firestore.collection(_collection).doc(id).update({
      'medicalConditions': FieldValue.arrayUnion([condition]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove medical condition
  Future<void> removeMedicalCondition(String id, String condition) async {
    await _firestore.collection(_collection).doc(id).update({
      'medicalConditions': FieldValue.arrayRemove([condition]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update donor preferences
  Future<void> updatePreferences(
      String id, Map<String, dynamic> preferences) async {
    await _firestore.collection(_collection).doc(id).update({
      'preferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get upcoming blood drives
  Stream<List<Map<String, dynamic>>> getUpcomingBloodDrives() {
    return _firestore
        .collection('blood_drives')
        .where('date', isGreaterThan: Timestamp.now())
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }
}

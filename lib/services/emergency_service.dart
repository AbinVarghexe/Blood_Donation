import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_request.dart';
import '../models/donor.dart';
import 'notification_service.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emergency_requests';
  final NotificationService _notificationService = NotificationService();

  // Create a new emergency request
  Future<EmergencyRequest> createRequest(EmergencyRequest request) async {
    final docRef =
        await _firestore.collection(_collection).add(request.toFirestore());
    final createdRequest = request.copyWith(id: docRef.id);

    // Notify eligible donors
    await _notifyEligibleDonors(createdRequest);

    return createdRequest;
  }

  // Get an emergency request by ID
  Future<EmergencyRequest?> getRequest(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return EmergencyRequest.fromFirestore(doc);
  }

  // Update an emergency request
  Future<void> updateRequest(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete an emergency request
  Future<void> deleteRequest(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get all active emergency requests
  Stream<List<EmergencyRequest>> getActiveRequests() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('requiredBy')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyRequest.fromFirestore(doc))
            .toList());
  }

  // Get emergency requests by hospital
  Stream<List<EmergencyRequest>> getRequestsByHospital(String hospitalId) {
    return _firestore
        .collection(_collection)
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyRequest.fromFirestore(doc))
            .toList());
  }

  // Get emergency requests by blood group
  Stream<List<EmergencyRequest>> getRequestsByBloodGroup(String bloodGroup) {
    return _firestore
        .collection(_collection)
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('status', isEqualTo: 'active')
        .orderBy('requiredBy')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyRequest.fromFirestore(doc))
            .toList());
  }

  // Respond to an emergency request
  Future<void> respondToRequest(String requestId, String donorId) async {
    final request = await getRequest(requestId);
    if (request == null) throw Exception('Request not found');

    if (!request.isActive) {
      throw Exception('Request is no longer active');
    }

    if (request.respondingDonors.contains(donorId)) {
      throw Exception('You have already responded to this request');
    }

    if (request.isFullyResponded) {
      throw Exception('Request is fully responded');
    }

    await _firestore.collection(_collection).doc(requestId).update({
      'respondingDonors': FieldValue.arrayUnion([donorId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }); // Notify hospital about the response
    await _notificationService.createEmergencyNotification(
      userId: request.hospitalId,
      requestId: requestId,
      title: 'New Donor Response',
      message:
          'A donor has responded to your emergency request for ${request.bloodGroup} blood.',
    );
  }

  // Cancel response to an emergency request
  Future<void> cancelResponse(String requestId, String donorId) async {
    final request = await getRequest(requestId);
    if (request == null) throw Exception('Request not found');

    if (!request.respondingDonors.contains(donorId)) {
      throw Exception('You have not responded to this request');
    }

    await _firestore.collection(_collection).doc(requestId).update({
      'respondingDonors': FieldValue.arrayRemove([donorId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }); // Notify hospital about the cancellation
    await _notificationService.createEmergencyNotification(
      userId: request.hospitalId,
      requestId: requestId,
      title: 'Donor Response Cancelled',
      message:
          'A donor has cancelled their response to your emergency request.',
    );
  }

  // Update request status
  Future<void> updateStatus(String requestId, String status) async {
    await _firestore.collection(_collection).doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get active requests near a location
  Stream<List<EmergencyRequest>> getActiveRequestsNearby(
      GeoPoint location, double radiusInKm) {
    // TODO: Implement geospatial query using GeoFirestore
    // For now, return all active requests
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('requiredBy')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyRequest.fromFirestore(doc))
            .toList());
  }

  // Notify eligible donors about an emergency request
  Future<void> _notifyEligibleDonors(EmergencyRequest request) async {
    // Get eligible donors with matching blood group
    final donors = await _firestore
        .collection('donors')
        .where('bloodGroup', isEqualTo: request.bloodGroup)
        .where('isEligible', isEqualTo: true)
        .get();

    // Send notifications to eligible donors
    for (final doc in donors.docs) {
      final donor = Donor.fromFirestore(doc);
      if (donor.canDonate) {
        await _notificationService.createEmergencyNotification(
          userId: donor.id,
          requestId: request.id,
          title: 'Urgent Blood Request',
          message:
              '${request.hospitalName} needs ${request.units} units of ${request.bloodGroup} blood. '
              'Required by: ${request.requiredBy.day}/${request.requiredBy.month}/${request.requiredBy.year}',
        );
      }
    }
  }
}

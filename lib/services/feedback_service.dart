import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback.dart';
import '../services/notification_service.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final String _collection = 'feedback';

  // Create new feedback
  Future<Feedback> createFeedback(Feedback feedback) async {
    final docRef =
        await _firestore.collection(_collection).add(feedback.toFirestore());
    final doc = await docRef.get();
    return Feedback.fromFirestore(doc);
  }

  // Get feedback by ID
  Future<Feedback?> getFeedback(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Feedback.fromFirestore(doc);
  }

  // Update feedback
  Future<void> updateFeedback(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete feedback
  Future<void> deleteFeedback(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get all feedback for a user
  Stream<List<Feedback>> getUserFeedback(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Get feedback by type
  Stream<List<Feedback>> getFeedbackByType(FeedbackType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Get feedback by status
  Stream<List<Feedback>> getFeedbackByStatus(FeedbackStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Get high priority feedback
  Stream<List<Feedback>> getHighPriorityFeedback() {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThanOrEqualTo: 4)
        .orderBy('rating', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Respond to feedback
  Future<void> respondToFeedback(
    String id,
    String response,
    String respondedBy,
  ) async {
    final feedback = await getFeedback(id);
    if (feedback == null) return;

    await updateFeedback(id, {
      'response': response,
      'respondedBy': respondedBy,
      'respondedAt': FieldValue.serverTimestamp(),
      'status': FeedbackStatus.resolved.toString().split('.').last,
    }); // Notify user about the response
    await _notificationService.createFeedbackResponseNotification(
      userId: feedback.userId,
      feedbackId: id,
      title: feedback.title,
      message: response,
    );
  }

  // Update feedback status
  Future<void> updateStatus(String id, FeedbackStatus status) async {
    await updateFeedback(id, {
      'status': status.toString().split('.').last,
    });
  }

  // Get feedback statistics
  Future<Map<String, dynamic>> getFeedbackStats() async {
    final snapshot = await _firestore.collection(_collection).get();
    final feedbacks =
        snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList();

    final Map<FeedbackType, int> typeCount = {};
    final Map<FeedbackStatus, int> statusCount = {};
    int totalRating = 0;
    int totalResponses = 0;
    Duration totalResponseTime = Duration.zero;

    for (var feedback in feedbacks) {
      typeCount[feedback.type] = (typeCount[feedback.type] ?? 0) + 1;
      statusCount[feedback.status] = (statusCount[feedback.status] ?? 0) + 1;
      totalRating += feedback.rating;
      if (feedback.hasResponse) {
        totalResponses++;
        totalResponseTime += feedback.responseTime;
      }
    }

    return {
      'totalFeedbacks': feedbacks.length,
      'typeDistribution': typeCount,
      'statusDistribution': statusCount,
      'averageRating': feedbacks.isEmpty ? 0 : totalRating / feedbacks.length,
      'responseRate': feedbacks.isEmpty ? 0 : totalResponses / feedbacks.length,
      'averageResponseTime': totalResponses == 0
          ? Duration.zero
          : Duration(
              milliseconds: totalResponseTime.inMilliseconds ~/ totalResponses),
    };
  }

  // Get feedback by date range
  Stream<List<Feedback>> getFeedbackByDateRange(
      DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(_collection)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Get unresolved feedback
  Stream<List<Feedback>> getUnresolvedFeedback() {
    return _firestore
        .collection(_collection)
        .where('status', whereIn: [
          FeedbackStatus.pending.toString().split('.').last,
          FeedbackStatus.inProgress.toString().split('.').last,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList());
  }

  // Submit feedback (alias for createFeedback)
  Future<Feedback> submitFeedback(Feedback feedback) async {
    return await createFeedback(feedback);
  }

  // Get all feedback (for admin/management purposes)
  Future<List<Feedback>> getAllFeedback() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList();
  }
}

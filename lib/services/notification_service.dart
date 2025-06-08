import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _collection = 'notifications';

  // Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // TODO: Store token in user's document
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) {
      // TODO: Update token in user's document
    });

    // Handle incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle incoming messages when app is in background
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  // Create a new notification
  Future<AppNotification> createNotification(
      AppNotification notification) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(notification.toFirestore());
    return notification.copyWith(id: docRef.id);
  }

  // Get notifications for a user
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_collection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).delete();
  }

  // Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create blood drive notification
  Future<void> createBloodDriveNotification({
    required String userId,
    required String bloodDriveId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: 'blood_drive',
      referenceId: bloodDriveId,
      createdAt: DateTime.now(),
      data: data,
    );

    await createNotification(notification);
    await _sendPushNotification(notification);
  }

  // Create emergency notification
  Future<void> createEmergencyNotification({
    required String userId,
    required String requestId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: 'emergency',
      referenceId: requestId,
      createdAt: DateTime.now(),
      data: data,
    );

    await createNotification(notification);
    await _sendPushNotification(notification);
  }

  // Send push notification
  Future<void> _sendPushNotification(AppNotification notification) async {
    // TODO: Implement Firebase Cloud Functions to send push notifications
    // This will be implemented using Firebase Cloud Functions
  }

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // TODO: Implement foreground message handling
    // Show local notification
  }
  // Handle background message
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // TODO: Implement background message handling
  }

  // Create feedback response notification
  Future<void> createFeedbackResponseNotification({
    required String userId,
    required String feedbackId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: 'feedback_response',
      referenceId: feedbackId,
      createdAt: DateTime.now(),
      data: data,
    );

    await createNotification(notification);
    await _sendPushNotification(notification);
  }

  // Create inventory alert notification
  Future<void> createInventoryAlert({
    required String userId,
    required String bloodType,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: 'inventory_alert',
      referenceId: bloodType,
      createdAt: DateTime.now(),
      data: data,
    );

    await createNotification(notification);
    await _sendPushNotification(notification);
  }
}

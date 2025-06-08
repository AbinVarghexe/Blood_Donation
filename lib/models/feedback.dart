import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackType {
  general,
  donation,
  emergency,
  inventory,
  technical,
  suggestion,
  complaint,
}

enum FeedbackStatus {
  pending,
  inProgress,
  resolved,
  closed,
}

class Feedback {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final FeedbackType type;
  final String title;
  final String message;
  final FeedbackStatus status;
  final String? response;
  final String? respondedBy;
  final DateTime? respondedAt;
  final int rating;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Feedback({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    this.response,
    this.respondedBy,
    this.respondedAt,
    required this.rating,
    this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Feedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Feedback(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'],
      userEmail: data['userEmail'],
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == 'FeedbackType.${data['type']}',
        orElse: () => FeedbackType.general,
      ),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString() == 'FeedbackStatus.${data['status']}',
        orElse: () => FeedbackStatus.pending,
      ),
      response: data['response'],
      respondedBy: data['respondedBy'],
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      rating: data['rating'] ?? 0,
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : null,
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'status': status.toString().split('.').last,
      'response': response,
      'respondedBy': respondedBy,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'rating': rating,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Feedback copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    FeedbackType? type,
    String? title,
    String? message,
    FeedbackStatus? status,
    String? response,
    String? respondedBy,
    DateTime? respondedAt,
    int? rating,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      response: response ?? this.response,
      respondedBy: respondedBy ?? this.respondedBy,
      respondedAt: respondedAt ?? this.respondedAt,
      rating: rating ?? this.rating,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isResolved => status == FeedbackStatus.resolved;
  bool get isClosed => status == FeedbackStatus.closed;
  bool get hasResponse => response != null && response!.isNotEmpty;
  bool get isHighPriority => rating >= 4;
  Duration get responseTime => respondedAt?.difference(createdAt) ?? Duration.zero;
} 
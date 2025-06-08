import 'package:flutter/material.dart';
import '../../models/feedback.dart' as feedback_model;
import '../../services/feedback_service.dart';
import '../../services/auth_service.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() =>
      _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<feedback_model.Feedback> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final feedbacks = await _feedbackService.getAllFeedback();
      setState(() {
        _feedbacks = feedbacks;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feedback: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _respondToFeedback(String feedbackId, String response) async {
    try {
      final user = await _authService.getCurrentUser();
      await _feedbackService.respondToFeedback(
          feedbackId, response, user?.uid ?? 'admin');
      await _loadFeedbacks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending response: $e')),
        );
      }
    }
  }

  void _showResponseDialog(feedback_model.Feedback feedback) {
    final TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: ${feedback.title}'),
            const SizedBox(height: 8),
            Text('Message: ${feedback.message}'),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Your Response',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (responseController.text.isNotEmpty) {
                _respondToFeedback(feedback.id, responseController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: Colors.red[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbacks.isEmpty
              ? const Center(
                  child: Text(
                    'No feedback available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeedbacks,
                  child: ListView.builder(
                    itemCount: _feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = _feedbacks[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(feedback.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(feedback.message),
                              const SizedBox(height: 4),
                              Text(
                                'From: ${feedback.userId}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (feedback.response != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      border:
                                          Border.all(color: Colors.green[200]!),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Response:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(feedback.response!),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: feedback.response == null
                              ? IconButton(
                                  icon: const Icon(Icons.reply),
                                  onPressed: () =>
                                      _showResponseDialog(feedback),
                                )
                              : const Icon(Icons.check_circle,
                                  color: Colors.green),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../services/feedback_service.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() =>
      _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final FeedbackService _feedbackService = FeedbackService();

  // Filters
  FeedbackModel.FeedbackType? _selectedType;
  FeedbackModel.FeedbackStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  Color _getStatusColor(FeedbackModel.FeedbackStatus status) {
    switch (status) {
      case FeedbackModel.FeedbackStatus.pending:
        return Colors.orange;
      case FeedbackModel.FeedbackStatus.inProgress:
        return Colors.blue;
      case FeedbackModel.FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackModel.FeedbackStatus.closed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          StreamBuilder<Map<String, dynamic>>(
            stream: Stream.fromFuture(_feedbackService.getFeedbackStats()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data!;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            stats['totalFeedbacks'].toString(),
                            Icons.feedback,
                          ),
                          _buildStatItem(
                            'Avg Rating',
                            stats['averageRating'].toStringAsFixed(1),
                            Icons.star,
                          ),
                          _buildStatItem(
                            'Response Rate',
                            '${(stats['responseRate'] * 100).toStringAsFixed(1)}%',
                            Icons.reply,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Feedback List
          Expanded(
            child: StreamBuilder<List<FeedbackModel.Feedback>>(
              stream: _getFilteredFeedbackStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbacks = snapshot.data!;
                if (feedbacks.isEmpty) {
                  return const Center(
                    child: Text('No feedback found'),
                  );
                }

                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    return _buildFeedbackCard(feedback);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(FeedbackModel.Feedback feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(feedback.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feedback.message),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                Text(' ${feedback.rating}'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(feedback.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback.status.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.reply),
          onPressed: () => _showResponseDialog(feedback),
        ),
        onTap: () => _showFeedbackDetails(feedback),
      ),
    );
  }

  Stream<List<FeedbackModel.Feedback>> _getFilteredFeedbackStream() {
    if (_selectedType != null) {
      return _feedbackService.getFeedbackByType(_selectedType!);
    }
    if (_selectedStatus != null) {
      return _feedbackService.getFeedbackByStatus(_selectedStatus!);
    }
    if (_startDate != null && _endDate != null) {
      return _feedbackService.getFeedbackByDateRange(_startDate!, _endDate!);
    }
    return _feedbackService.getUnresolvedFeedback();
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<FeedbackModel.FeedbackType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Feedback Type',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                ...FeedbackModel.FeedbackType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FeedbackModel.FeedbackStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Status'),
                ),
                ...FeedbackModel.FeedbackStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedStatus = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResponseDialog(FeedbackModel.Feedback feedback) async {
    final responseController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Feedback'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            labelText: 'Your Response',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isEmpty) return;

              try {
                await _feedbackService.respondToFeedback(
                  feedback.id,
                  responseController.text.trim(),
                  'admin', // Mock admin ID
                );
                if (mounted) {
                  Navigator.pop(context);
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
            },
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDetails(FeedbackModel.Feedback feedback) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feedback.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type: ${feedback.type.toString().split('.').last}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${feedback.status.toString().split('.').last}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rating: ${feedback.rating}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(feedback.message),
              if (feedback.hasResponse) ...[
                const SizedBox(height: 16),
                const Text(
                  'Response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(feedback.response!),
                const SizedBox(height: 8),
                Text(
                  'Responded by: ${feedback.respondedBy}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!feedback.hasResponse)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showResponseDialog(feedback);
              },
              child: const Text('Respond'),
            ),
        ],
      ),
    );
  }
}

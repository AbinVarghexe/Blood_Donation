import 'package:flutter/material.dart';
import '../../models/emergency_request.dart';
import '../../services/emergency_service.dart';
import '../../services/auth_service.dart';

class EmergencyRequestDetailsScreen extends StatefulWidget {
  final EmergencyRequest request;

  const EmergencyRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  State<EmergencyRequestDetailsScreen> createState() => _EmergencyRequestDetailsScreenState();
}

class _EmergencyRequestDetailsScreenState extends State<EmergencyRequestDetailsScreen> {
  final _emergencyService = EmergencyService();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _respondToRequest() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _emergencyService.respondToRequest(widget.request.id, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error responding to request: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelResponse() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _emergencyService.cancelResponse(widget.request.id, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling response: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final userId = _authService.currentUser?.uid;
    final hasResponded = userId != null && request.respondingDonors.contains(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Request Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: request.isUrgent ? Colors.red.shade50 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                request.isUrgent ? Icons.warning : Icons.info,
                                color: request.isUrgent ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                request.isUrgent ? 'Urgent Request' : 'Emergency Request',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: request.isUrgent ? Colors.red : null,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${request.status.toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (request.isActive) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${request.remainingUnits} units remaining',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: request.remainingUnits > 0 ? Colors.green : Colors.red,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hospital Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hospital Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem('Hospital', request.hospitalName),
                          _buildInfoItem('Address', request.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Request Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem('Blood Group', request.bloodGroup),
                          _buildInfoItem('Units Required', request.units.toString()),
                          _buildInfoItem('Required By', 
                            '${request.requiredBy.day}/${request.requiredBy.month}/${request.requiredBy.year} '
                            '${request.requiredBy.hour}:${request.requiredBy.minute.toString().padLeft(2, '0')}',
                          ),
                          _buildInfoItem('Reason', request.reason),
                          _buildInfoItem('Patient Details', request.patientDetails),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Response Section
                  if (request.isActive && userId != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Response',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            if (hasResponded)
                              const Text(
                                'You have responded to this request. Please proceed to the hospital as soon as possible.',
                                style: TextStyle(color: Colors.green),
                              )
                            else
                              const Text(
                                'You can respond to this request if you are eligible to donate.',
                                style: TextStyle(color: Colors.orange),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: hasResponded ? _cancelResponse : _respondToRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasResponded ? Colors.red : Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  hasResponded ? 'Cancel Response' : 'Respond to Request',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 
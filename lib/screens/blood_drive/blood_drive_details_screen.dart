import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blood_drive.dart';
import '../../services/blood_drive_service.dart';
import '../../providers/auth_provider.dart';
import 'create_blood_drive_screen.dart';
import 'register_for_drive_screen.dart';

class BloodDriveDetailsScreen extends StatefulWidget {
  final String bloodDriveId;

  const BloodDriveDetailsScreen({
    super.key,
    required this.bloodDriveId,
  });

  @override
  State<BloodDriveDetailsScreen> createState() =>
      _BloodDriveDetailsScreenState();
}

class _BloodDriveDetailsScreenState extends State<BloodDriveDetailsScreen> {
  final _bloodDriveService = BloodDriveService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Drive Details'),
        actions: [
          StreamBuilder<BloodDrive?>(
            stream: _bloodDriveService.getBloodDriveStream(widget.bloodDriveId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final bloodDrive = snapshot.data!;
              final user = Provider.of<AuthProvider>(context).user;

              if (user?.uid == bloodDrive.organizerId) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateBloodDriveScreen(
                          bloodDrive: bloodDrive,
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<BloodDrive?>(
        stream: _bloodDriveService.getBloodDriveStream(widget.bloodDriveId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Blood drive not found'));
          }

          final bloodDrive = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(bloodDrive),
                const SizedBox(height: 24),
                _buildDetails(bloodDrive),
                const SizedBox(height: 24), _buildDonorList(bloodDrive),
                // Registration Button for Donors
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.user?.role == 'donor') {
                      return Column(
                        children: [
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterForDriveScreen(
                                      bloodDriveId: bloodDrive.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.how_to_reg),
                              label: const Text('Register as Donor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BloodDrive bloodDrive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bloodDrive.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              bloodDrive.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bloodDrive.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(bloodDrive.startDate)} - ${_formatDate(bloodDrive.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(BloodDrive bloodDrive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drive Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  'Target Donors',
                  bloodDrive.targetDonors.toString(),
                  Icons.people,
                ),
                _buildDetailItem(
                  'Registered',
                  bloodDrive.registeredDonors.toString(),
                  Icons.how_to_reg,
                ),
                _buildDetailItem(
                  'Status',
                  bloodDrive.status,
                  Icons.info,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Target Blood Groups',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: bloodDrive.targetBloodGroups.map((group) {
                return Chip(
                  label: Text(group),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDonorList(BloodDrive bloodDrive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registered Donors',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${bloodDrive.registeredDonors}/${bloodDrive.targetDonors}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bloodDrive.registeredDonorIds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No donors registered yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bloodDrive.registeredDonorIds.length,
                itemBuilder: (context, index) {
                  final donorId = bloodDrive.registeredDonorIds[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Donor ${index + 1}'),
                    subtitle: Text('ID: $donorId'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // TODO: Implement donor removal
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

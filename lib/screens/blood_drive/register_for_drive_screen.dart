import 'package:flutter/material.dart';
import '../../models/blood_drive.dart';
import '../../services/blood_drive_service.dart';
import '../../services/auth_service.dart';

class RegisterForDriveScreen extends StatefulWidget {
  final String bloodDriveId;

  const RegisterForDriveScreen({
    super.key,
    required this.bloodDriveId,
  });

  @override
  _RegisterForDriveScreenState createState() => _RegisterForDriveScreenState();
}

class _RegisterForDriveScreenState extends State<RegisterForDriveScreen> {
  final _bloodDriveService = BloodDriveService();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final bloodDrive =
          await _bloodDriveService.getBloodDrive(widget.bloodDriveId);
      if (bloodDrive != null) {
        setState(() {
          _isRegistered = bloodDrive.registeredDonorIds.contains(user.uid);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleRegistration() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      if (_isRegistered) {
        await _bloodDriveService.unregisterDonor(widget.bloodDriveId, user.uid);
      } else {
        await _bloodDriveService.registerDonor(widget.bloodDriveId, user.uid);
      }

      setState(() => _isRegistered = !_isRegistered);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Blood Drive'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<BloodDrive?>(
              stream: _bloodDriveService
                  .getBloodDrive(widget.bloodDriveId)
                  .asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final bloodDrive = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blood Drive Information
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bloodDrive.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bloodDrive.description,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location and Dates
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: const Text('Location'),
                                subtitle: Text(bloodDrive.location),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Start Date'),
                                subtitle: Text(
                                  bloodDrive.startDate.toString().split(' ')[0],
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('End Date'),
                                subtitle: Text(
                                  bloodDrive.endDate.toString().split(' ')[0],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Blood Groups
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Blood Groups',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    bloodDrive.targetBloodGroups.map((group) {
                                  return Chip(
                                    label: Text(group),
                                    backgroundColor: Colors.red[100],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Donor Progress
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Donor Progress',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: bloodDrive.registeredDonors /
                                    bloodDrive.targetDonors,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${bloodDrive.registeredDonors} / ${bloodDrive.targetDonors} donors registered',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registration Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _toggleRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isRegistered ? Colors.red : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isRegistered ? 'Unregister' : 'Register Now',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (_isRegistered) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.green[50],
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'You are registered for this blood drive!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please arrive at the location on the scheduled date and time.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

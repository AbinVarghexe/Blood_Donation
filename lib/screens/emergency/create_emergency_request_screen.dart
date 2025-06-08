import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/emergency_request.dart';
import '../../services/emergency_service.dart';
import '../../services/auth_service.dart';

class CreateEmergencyRequestScreen extends StatefulWidget {
  const CreateEmergencyRequestScreen({super.key});

  @override
  State<CreateEmergencyRequestScreen> createState() => _CreateEmergencyRequestScreenState();
}

class _CreateEmergencyRequestScreenState extends State<CreateEmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyService = EmergencyService();
  final _authService = AuthService();
  bool _isLoading = false;

  final _bloodGroupController = TextEditingController();
  final _unitsController = TextEditingController();
  final _reasonController = TextEditingController();
  final _patientDetailsController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime _requiredBy = DateTime.now().add(const Duration(hours: 24));
  GeoPoint? _location;

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _unitsController.dispose();
    _reasonController.dispose();
    _patientDetailsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final request = EmergencyRequest(
        id: '', // Will be set by Firestore
        hospitalId: user.uid,
        hospitalName: user.displayName ?? 'Unknown Hospital',
        bloodGroup: _bloodGroupController.text,
        units: int.parse(_unitsController.text),
        reason: _reasonController.text,
        patientDetails: _patientDetailsController.text,
        location: _location!,
        address: _addressController.text,
        requiredBy: _requiredBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _emergencyService.createRequest(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency request created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating request: $e')),
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
        title: const Text('Create Emergency Request'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blood Group
                    DropdownButtonFormField<String>(
                      value: _bloodGroupController.text.isEmpty
                          ? null
                          : _bloodGroupController.text,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group',
                        border: OutlineInputBorder(),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _bloodGroupController.text = value);
                        }
                      },
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please select a blood group' : null,
                    ),
                    const SizedBox(height: 16),

                    // Units Required
                    TextFormField(
                      controller: _unitsController,
                      decoration: const InputDecoration(
                        labelText: 'Units Required',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the number of units';
                        }
                        final units = int.tryParse(value!);
                        if (units == null || units <= 0) {
                          return 'Please enter a valid number of units';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reason
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Request',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a reason' : null,
                    ),
                    const SizedBox(height: 16),

                    // Patient Details
                    TextFormField(
                      controller: _patientDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter patient details' : null,
                    ),
                    const SizedBox(height: 16),

                    // Required By
                    ListTile(
                      title: const Text('Required By'),
                      subtitle: Text(
                        '${_requiredBy.day}/${_requiredBy.month}/${_requiredBy.year} '
                        '${_requiredBy.hour}:${_requiredBy.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _requiredBy,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 7)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_requiredBy),
                          );
                          if (time != null) {
                            setState(() {
                              _requiredBy = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter the hospital address' : null,
                      onChanged: (value) {
                        // TODO: Implement geocoding to get coordinates
                        // For now, use a dummy location
                        _location = const GeoPoint(0, 0);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Create Emergency Request',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 
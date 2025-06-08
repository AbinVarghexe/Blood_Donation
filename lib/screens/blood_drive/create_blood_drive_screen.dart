import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/blood_drive.dart';
import '../../services/blood_drive_service.dart';
import '../../providers/auth_provider.dart';

class CreateBloodDriveScreen extends StatefulWidget {
  final BloodDrive? bloodDrive;

  const CreateBloodDriveScreen({super.key, this.bloodDrive});

  @override
  State<CreateBloodDriveScreen> createState() => _CreateBloodDriveScreenState();
}

class _CreateBloodDriveScreenState extends State<CreateBloodDriveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodDriveService = BloodDriveService();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _targetDonors = 50;
  final List<String> _selectedBloodGroups = [];
  GeoPoint? _coordinates;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bloodDrive != null) {
      _titleController.text = widget.bloodDrive!.title;
      _descriptionController.text = widget.bloodDrive!.description;
      _locationController.text = widget.bloodDrive!.location;
      _startDate = widget.bloodDrive!.startDate;
      _endDate = widget.bloodDrive!.endDate;
      _targetDonors = widget.bloodDrive!.targetDonors;
      _selectedBloodGroups.addAll(widget.bloodDrive!.targetBloodGroups);
      _coordinates = widget.bloodDrive!.coordinates;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectLocation() async {
    // TODO: Implement location picker with Google Maps
    // For now, using a placeholder coordinate
    setState(() {
      _coordinates = const GeoPoint(0.0, 0.0);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }
    if (_selectedBloodGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one blood group')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) throw Exception('User not authenticated');

      final bloodDrive = BloodDrive(
        id: widget.bloodDrive?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        coordinates: _coordinates!,
        startDate: _startDate!,
        endDate: _endDate!,
        organizerId: user.uid,
        organizerName: user.displayName ?? 'Unknown',
        targetBloodGroups: _selectedBloodGroups,
        targetDonors: _targetDonors,
        createdAt: widget.bloodDrive?.createdAt ?? DateTime.now(),
      );

      if (widget.bloodDrive == null) {
        await _bloodDriveService.createBloodDrive(bloodDrive);
      } else {
        await _bloodDriveService.updateBloodDrive(bloodDrive);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bloodDrive == null ? 'Create Blood Drive' : 'Edit Blood Drive'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter blood drive title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter blood drive description',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter blood drive location',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _selectLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Select Location on Map'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Not selected'),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not selected'),
                            onTap: () => _selectDate(context, false),
                          ),
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
                      children: _bloodGroups.map((group) {
                        final isSelected = _selectedBloodGroups.contains(group);
                        return FilterChip(
                          label: Text(group),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedBloodGroups.add(group);
                              } else {
                                _selectedBloodGroups.remove(group);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Target Number of Donors: $_targetDonors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider(
                      value: _targetDonors.toDouble(),
                      min: 10,
                      max: 200,
                      divisions: 19,
                      label: _targetDonors.toString(),
                      onChanged: (value) {
                        setState(() {
                          _targetDonors = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.bloodDrive == null ? 'Create Blood Drive' : 'Update Blood Drive',
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
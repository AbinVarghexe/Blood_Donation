import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donor.dart';
import '../../services/donor_service.dart';
import '../../services/auth_service.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorService = DonorService();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isEditing = false;
  late Donor _donor;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String _selectedBloodGroup = 'A+';
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 18));

  @override
  void initState() {
    super.initState();
    _loadDonorProfile();
  }

  Future<void> _loadDonorProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final donor = await _donorService.getDonor(userId);
        if (donor != null) {
          setState(() {
            _donor = donor;
            _nameController = TextEditingController(text: donor.name);
            _phoneController = TextEditingController(text: donor.phone);
            _addressController = TextEditingController(text: donor.address);
            _selectedBloodGroup = donor.bloodGroup;
            _selectedDate = donor.dateOfBirth;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _donorService.updateDonor(userId, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'bloodGroup': _selectedBloodGroup,
          'dateOfBirth': Timestamp.fromDate(_selectedDate),
        });
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _donor.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      _donor.bloodGroup,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Donation Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusItem(
                            'Eligible',
                            _donor.isEligible ? 'Yes' : 'No',
                            _donor.isEligible ? Colors.green : Colors.red,
                          ),
                          _buildStatusItem(
                            'Last Donation',
                            _donor.lastDonationDate != null
                                ? '${_donor.lastDonationDate!.day}/${_donor.lastDonationDate!.month}/${_donor.lastDonationDate!.year}'
                                : 'Never',
                            Colors.blue,
                          ),
                          _buildStatusItem(
                            'Next Donation',
                            _donor.canDonate
                                ? 'Available'
                                : '${_donor.daysUntilNextDonation} days',
                            _donor.canDonate ? Colors.green : Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedBloodGroup,
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
                              setState(() => _selectedBloodGroup = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Date of Birth'),
                          subtitle: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                        ),
                      ] else ...[
                        _buildInfoItem('Email', _donor.email),
                        _buildInfoItem('Phone', _donor.phone ?? 'Not provided'),
                        _buildInfoItem('Address', _donor.address ?? 'Not provided'),
                        _buildInfoItem('Blood Group', _donor.bloodGroup),
                        _buildInfoItem(
                          'Date of Birth',
                          '${_donor.dateOfBirth.day}/${_donor.dateOfBirth.month}/${_donor.dateOfBirth.year}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Medical Conditions
              if (_donor.medicalConditions.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical Conditions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: _donor.medicalConditions
                              .map((condition) => Chip(
                                    label: Text(condition),
                                    backgroundColor: Colors.red.shade100,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
} 
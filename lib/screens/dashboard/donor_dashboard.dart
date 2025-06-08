import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/donor_service.dart';
import '../../services/blood_drive_service.dart';
import '../../models/donor.dart';
import '../../models/blood_drive.dart';
import '../profile/donor_profile_screen.dart';
import '../blood_drive/blood_drive_details_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _authService = AuthService();
  final _donorService = DonorService();
  final _bloodDriveService = BloodDriveService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildDonateTab(),
          _buildHistoryTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return StreamBuilder<Donor?>(
      stream: _donorService.getDonorStream(_authService.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final donor = snapshot.data;
        if (donor == null) {
          return const Center(child: Text('Error loading donor data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${donor.name}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Blood Group: ${donor.bloodGroup}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                            donor.isEligible ? 'Yes' : 'No',
                            donor.isEligible ? Colors.green : Colors.red,
                          ),
                          _buildStatusItem(
                            'Last Donation',
                            donor.lastDonationDate != null
                                ? '${donor.lastDonationDate!.day}/${donor.lastDonationDate!.month}/${donor.lastDonationDate!.year}'
                                : 'Never',
                            Colors.blue,
                          ),
                          _buildStatusItem(
                            'Next Donation',
                            donor.canDonate
                                ? 'Available'
                                : '${donor.daysUntilNextDonation} days',
                            donor.canDonate ? Colors.green : Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upcoming Blood Drives
              Text(
                'Upcoming Blood Drives',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<BloodDrive>>(
                stream: _bloodDriveService.getUpcomingBloodDrives(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final drives = snapshot.data ?? [];
                  if (drives.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No upcoming blood drives'),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: drives.length,
                    itemBuilder: (context, index) {
                      final drive = drives[index];
                      return Card(
                        child: ListTile(
                          title: Text(drive.title),
                          subtitle: Text(
                            '${drive.location} • ${drive.startDate.day}/${drive.startDate.month}/${drive.startDate.year}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BloodDriveDetailsScreen(
                                  bloodDriveId: drive.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonateTab() {
    return StreamBuilder<Donor?>(
      stream: _donorService.getDonorStream(_authService.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final donor = snapshot.data;
        if (donor == null) {
          return const Center(child: Text('Error loading donor data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donation Eligibility
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Eligibility',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (donor.canDonate)
                        const Text(
                          'You are eligible to donate blood! Find a blood drive or hospital near you.',
                          style: TextStyle(color: Colors.green),
                        )
                      else
                        Text(
                          'You can donate blood in ${donor.daysUntilNextDonation} days.',
                          style: const TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Register for Blood Drive
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register for Blood Drive',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Blood Drive ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: donor.canDonate
                              ? () {
                                  // TODO: Implement blood drive registration
                                }
                              : null,
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Find Blood Drives
              Text(
                'Find Blood Drives',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<BloodDrive>>(
                stream: _bloodDriveService.getUpcomingBloodDrives(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final drives = snapshot.data ?? [];
                  if (drives.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No upcoming blood drives'),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: drives.length,
                    itemBuilder: (context, index) {
                      final drive = drives[index];
                      return Card(
                        child: ListTile(
                          title: Text(drive.title),
                          subtitle: Text(
                            '${drive.location} • ${drive.startDate.day}/${drive.startDate.month}/${drive.startDate.year}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BloodDriveDetailsScreen(
                                  bloodDriveId: drive.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<Donor?>(
      stream: _donorService.getDonorStream(_authService.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final donor = snapshot.data;
        if (donor == null) {
          return const Center(child: Text('Error loading donor data'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donation History
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (donor.lastDonationDate != null)
                        ListTile(
                          leading: const Icon(Icons.bloodtype),
                          title: const Text('Last Donation'),
                          subtitle: Text(
                            '${donor.lastDonationDate!.day}/${donor.lastDonationDate!.month}/${donor.lastDonationDate!.year}',
                          ),
                        )
                      else
                        const Text('No donation history'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Medical History
              if (donor.medicalConditions.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: donor.medicalConditions
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
        );
      },
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
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'base_dashboard.dart';
import '../blood_drive/create_blood_drive_screen.dart';
import '../../models/blood_drive.dart';
import '../../services/blood_drive_service.dart';
import '../../services/auth_service.dart';

class OrganizationDashboard extends StatefulWidget {
  const OrganizationDashboard({super.key});

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  final _bloodDriveService = BloodDriveService();
  final _authService = AuthService();
  String? _organizationName;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  Future<void> _loadOrganizationData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _organizationName = user.displayName;
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      title: 'Organization Dashboard',
      tabs: [
        _buildHomeTab(context),
        _buildBloodDrivesTab(context),
        _buildAnalyticsTab(context),
        _buildProfileTab(context),
      ],
      bottomNavItems: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bloodtype),
          label: 'Drives',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_organizationName ?? 'Organization'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your blood drives and engage with donors',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming Blood Drives Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Blood Drives',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateBloodDriveScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Drive'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentUserId != null)
            StreamBuilder<List<BloodDrive>>(
              stream:
                  _bloodDriveService.getBloodDrivesByOrganizer(_currentUserId!),
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

                final bloodDrives = snapshot.data!;
                if (bloodDrives.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No blood drives scheduled yet.\nCreate your first blood drive!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bloodDrives.length,
                  itemBuilder: (context, index) {
                    final drive = bloodDrives[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(drive.title),
                        subtitle: Text(
                          '${drive.location}\n'
                          '${drive.startDate.toString().split(' ')[0]} - '
                          '${drive.endDate.toString().split(' ')[0]}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${drive.registeredDonors}/${drive.targetDonors}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateBloodDriveScreen(
                                      bloodDrive: drive,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Navigate to blood drive details
                        },
                      ),
                    );
                  },
                );
              },
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Loading organization data...'),
              ),
            ),

          const SizedBox(height: 24),

          // Donor Statistics Section
          Text(
            'Donor Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Donors',
                  '1,234',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Donors',
                  '567',
                  Icons.person,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodDrivesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Drive Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBloodDriveScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Drive'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Blood Drives',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Blood drives will be listed here.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Drives',
                  '8',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Donors',
                  '142',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organization Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('Organization Name'),
                    subtitle: Text(_organizationName ?? 'Loading...'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Contact Email'),
                    subtitle: Text('contact@organization.com'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

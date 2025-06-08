import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../notifications/notifications_screen.dart';

class BaseDashboard extends StatefulWidget {
  final List<Widget> tabs;
  final List<BottomNavigationBarItem> bottomNavItems;
  final String title;

  const BaseDashboard({
    super.key,
    required this.tabs,
    required this.bottomNavItems,
    required this.title,
  });

  @override
  State<BaseDashboard> createState() => _BaseDashboardState();
}

class _BaseDashboardState extends State<BaseDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: widget.bottomNavItems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show emergency request dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Emergency Request'),
              content: const Text(
                'Are you sure you want to send an emergency blood request? This will notify all nearby eligible donors.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement emergency request
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Request'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.emergency),
      ),
    );
  }
} 
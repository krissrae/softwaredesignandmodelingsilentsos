import 'package:flutter/material.dart';
import 'package:silentsos/pre_alert_countdown_page.dart';
import 'package:silentsos/user.dart';

import '../profile_page.dart';
import '../stats_page.dart';
import '../styles.dart';

class HomeDashboardPage extends StatefulWidget {
  final VoidCallback onPressSOS;
  final VoidCallback toggleTheme;
  final User? user;

  const HomeDashboardPage({
    super.key,
    required this.onPressSOS,
    required this.toggleTheme,
    this.user,
  });

    // Replace with your actual Home content widget
  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = <Widget>[
    _buildHomePage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Welcome to SilentSOS',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About SilentSOS'),
                  content: const Text(
                    'SilentSOS helps you stay safe. In an emergency, '
                        'you can quickly send a silent alert to your trusted '
                        'contacts, sharing your situation and location without '
                        'drawing attention.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Brief Description'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.visibility, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('SilentSOS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreAlertCountdownPage(
                onFinished: () {
                  Navigator.pop(context);
                  widget.onPressSOS();
                },
                onCancel: () => Navigator.pop(context),
              ),
            ),
          );
        },
        tooltip: 'SOS',
        child: const Icon(Icons.warning),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

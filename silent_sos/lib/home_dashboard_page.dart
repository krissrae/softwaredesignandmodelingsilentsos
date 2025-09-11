import 'package:flutter/material.dart';
import '../profile_page.dart';
import '../stats_page.dart';
import '../styles.dart';
import '../user.dart';

class HomeDashboardPage extends StatefulWidget {
  final VoidCallback onPressSOS;
  const HomeDashboardPage({super.key, required this.onPressSOS, required void Function() toggleTheme, User? user});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    // Replace with your actual Home content widget
    Center(child: Text('Home')),
    StatsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Row(children: [
          Icon(Icons.visibility, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('SilentSOS'),
        ]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
        onPressed: widget.onPressSOS,
        child: Icon(Icons.warning),
        tooltip: 'SOS',
      ),
      // Added ElevatedButton for brief description
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Brief Description'),
                content: Text(
                  'SilentSOS is an app designed to help you stay safe. When you are in danger, you can quickly send a silent signal to your trusted contacts, alerting them to your situation and location without drawing attention.'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: Text('Brief description'),
        ),
      ],
    );
  }
}

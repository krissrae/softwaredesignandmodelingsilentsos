import 'package:flutter/material.dart';
import '../styles.dart';
import 'package:silentsos/user.dart';

class ProfilePage extends StatelessWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: AppColors.bg, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: roundedCard(
          radius: 34,
          child: Column(
            children: [
              Container(
                height: 96, width: 96,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
              ),
              const SizedBox(height: 18),
              _InfoLine(label: 'Name:', value: user?.name ?? ''),
              const SizedBox(height: 8),
              _InfoLine(label: 'Email:', value: user?.email ?? ''),
              const SizedBox(height: 8),
              const _InfoLine(label: 'TrustScore:'),
              const SizedBox(height: 8),
              const _InfoLine(label: 'Post Alerts:'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoLine({required this.label, this.value});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label ${value ?? ''}', style: const TextStyle(color: Colors.black54)),
      const Divider(thickness: 1.5),
    ]);
  }
}

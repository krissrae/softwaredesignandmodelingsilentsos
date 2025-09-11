import 'package:flutter/material.dart';
import 'styles.dart';

class ReceiverAlertPage extends StatelessWidget {
  const ReceiverAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: roundedCard(
            radius: 36,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header logo
                Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('SILENTSOS', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),

                // Avatar
                Center(
                  child: CircleAvatar(radius: 56, backgroundColor: Colors.pink.shade100),
                ),
                const SizedBox(height: 22),

                // Name line
                const _Line(label: 'Name:'),
                const SizedBox(height: 16),

                // Location + open maps
                ElevatedButton(
                  style: pillButton(Colors.brown.shade300),
                  onPressed: () {},
                  child: const Text('Location:'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: pillButton(Colors.brown.shade400),
                  onPressed: () {},
                  child: const Text('Open on Google maps'),
                ),
                const SizedBox(height: 18),

                // Mic access note card
                roundedCard(
                  color: const Color(0xFF4A75A0), // blue note
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(text: TextSpan(
                        style: const TextStyle(color: Colors.white),
                        children: const [
                          TextSpan(text: 'NOTE: ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                          TextSpan(text: 'This will give you access to the user’s microphone for 10 seconds.'),
                        ],
                      )),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: pillButton(const Color(0xFF2A0F0F), pad: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                          onPressed: () {},
                          child: const Text('Get Access'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Credibility score chip-like
                ElevatedButton(
                  style: pillButton(Colors.grey.shade700),
                  onPressed: () {},
                  child: const Text('Credibility Score:'),
                ),

                const Spacer(),
                // Bottom actions
                Row(
                  children: [
                    Expanded(child: ElevatedButton(style: pillButton(AppColors.dark), onPressed: () {}, child: const Text('Reject'))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(style: pillButton(AppColors.danger), onPressed: () {}, child: const Text('Endorse'))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(style: pillButton(AppColors.muted), onPressed: () {}, child: const Text('Ignore'))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  const _Line({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Divider(thickness: 1.5),
      ],
    );
  }
}

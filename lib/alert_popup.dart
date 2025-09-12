import 'package:flutter/material.dart';
import '../styles.dart';

Future<void> showIncomingAlertDialog(BuildContext context, {required String name}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: rounded(24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.notification_important, size: 48, color: AppColors.danger),
          const SizedBox(height: 10),
          Text('🚨 $name is in danger nearby!', textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(style: pillButton(AppColors.primary), onPressed: () {}, child: const Text('Call now'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(style: pillButton(AppColors.dark), onPressed: () {}, child: const Text('View location'))),
          ]),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Dismiss')),
        ]),
      ),
    ),
  );
}

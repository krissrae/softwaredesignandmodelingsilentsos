import 'dart:async';
import 'package:flutter/material.dart';
import '../styles.dart';

class PreAlertCountdownPage extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onFinished;
  const PreAlertCountdownPage({super.key, this.onCancel, this.onFinished});

  @override
  State<PreAlertCountdownPage> createState() => _PreAlertCountdownPageState();
}

class _PreAlertCountdownPageState extends State<PreAlertCountdownPage> {
  static const total = 5;
  late Timer _timer;
  int remaining = total;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining <= 1) {
        t.cancel();
        widget.onFinished?.call();
      }
      setState(() => remaining = (remaining - 1).clamp(0, total));
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final progress = (total - remaining) / total;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: roundedCard(
              color: AppColors.primary.withOpacity(.25),
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 140, width: 140,
                        child: CircularProgressIndicator(
                          value: progress, strokeWidth: 10,
                          backgroundColor: Colors.white.withOpacity(.6),
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      Text('$remaining', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Sending ALERT in seconds', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: pillButton(AppColors.danger, pad: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    onPressed: () {
                      _timer.cancel();
                      widget.onCancel?.call();
                      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

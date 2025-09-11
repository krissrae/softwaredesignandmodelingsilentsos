import 'package:flutter/material.dart';
import '../styles.dart';
import '../user.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Sign up'), backgroundColor: AppColors.bg, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            roundedCard(child: Column(
              children: const [
                _LineField(label: 'Full name'),
                SizedBox(height: 10),
                _LineField(label: 'Student email'),
                SizedBox(height: 10),
                _LineField(label: 'Password', obscure: true),
                SizedBox(height: 10),
                _LineField(label: 'Confirm password', obscure: true),
              ],
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: true, onChanged: (_) {}),
                const Expanded(child: Text('I agree to the Terms of Use')),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: pillButton(AppColors.primary),
              onPressed: () {
                // Get values from fields (you may need to use controllers for real input)
                final name = 'New User'; // Replace with actual input
                final email = 'student@example.com'; // Replace with actual input
                Navigator.pushNamed(
                  context,
                  '/dashboard',
                  arguments: User(name: name, email: email),
                );
              },
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineField extends StatelessWidget {
  final String label; final bool obscure;
  const _LineField({required this.label, this.obscure = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}

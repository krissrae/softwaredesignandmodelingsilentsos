import 'package:flutter/material.dart';
import '../styles.dart';
import '../user.dart';
import 'services/google_auth_service.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final user = await GoogleAuthService().signInWithGoogle();
    if (user != null) {
      // You can send user.authentication.idToken to your backend here
      Navigator.pushNamed(
        context,
        '/dashboard',
        arguments: User(name: user.displayName ?? '', email: user.email),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            roundedCard(
              child: Column(
                children: const [
                  _LineField(label: 'Full name'),
                  SizedBox(height: 10),
                  _LineField(label: 'Student email'),
                  SizedBox(height: 10),
                  _LineField(label: 'Password', obscure: true),
                  SizedBox(height: 10),
                  _LineField(label: 'Confirm password', obscure: true),
                ],
              ),
            ),
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
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: pillButton(Colors.white),
              icon: Image.asset('assets/google_logo.png', height: 24),
              label: const Text('Sign up with Google', style: TextStyle(color: Colors.black)),
              onPressed: () => _handleGoogleSignIn(context),
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

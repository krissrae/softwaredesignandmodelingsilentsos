import 'package:flutter/material.dart';
import 'styles.dart';
import 'user.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Login'), backgroundColor: AppColors.bg, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              roundedCard(child: Column(
                children: [
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email (student domain)', border: UnderlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: UnderlineInputBorder()),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final email = emailCtrl.text;
                  final name = email.split('@').first; // Example: use part before @ as name
                  Navigator.pushNamed(
                    context,
                    '/dashboard',
                    arguments: User(name: name, email: email),
                  );
                },
                child: Text('Login'),
              ),
              TextButton(onPressed: () {}, child: const Text('Create an account')),
            ],
          ),
        ),
      ),
    );
  }
}

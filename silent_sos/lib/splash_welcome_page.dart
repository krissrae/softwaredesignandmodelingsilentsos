import 'package:flutter/material.dart';
import '../styles.dart';

class SplashWelcomePage extends StatelessWidget {
  final VoidCallback? toggleTheme;
  const SplashWelcomePage({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Logo
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    // Replace with your Image.asset('assets/logo.png', height: 96)
                    Icon(Icons.visibility, size: 92, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text('SILENTSOS', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 2, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Your silent watcher', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Spacer(),
              roundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: pillButton(AppColors.primary),
                      onPressed: () {},
                      child: const Text('Brief Description'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: pillButton(AppColors.primary),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login using Google'),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.login),
                                title: Text('Login'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/login');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.person_add),
                                title: Text('Sign Up'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/signup');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text('Get started'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

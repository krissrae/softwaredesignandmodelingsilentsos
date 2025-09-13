import 'package:flutter/material.dart';
import 'services/api_service.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _apiController = ApiService();
  String message = "";

  void _login() async {
    final email = _emailController.text.trim();
    if(!email.endsWith("@ictuniversity.edu.cm")) {
      setState(() {
        message = "Use your ICTU email only!";
      });
      return;
    }

    bool success = await _apiController.loginWithSchoolEmail(email);
    setState(() {
      message = success ? "Login was successful": "Login failed";
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text ("SilentSOS Login")),
      body: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "School Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _login, child: const Text("Login"),
            ),
            const SizedBox(height: 10,),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
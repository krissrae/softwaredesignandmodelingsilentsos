import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SilentSOS Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                //trigger for alert
              },
              child: const Text("Send SOS"),
            ),
            const SizedBox(height: 20),
            const Text("Your location: "),
            //placeholder for map location display
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(child: Text("Map link goes here")),
            ),
          ],
        ),
      ),
    );
  }
}
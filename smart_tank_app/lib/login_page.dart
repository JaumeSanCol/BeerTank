// File: login_page.dart

import 'package:flutter/material.dart';

import 'main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SmartTank',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40), // Space between title and fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Customer ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Define input type for numbers
              ),
              const SizedBox(height: 20), // Space between fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Hide password input
              ),
              const SizedBox(height: 40), // Space before the button
              ElevatedButton(
                onPressed: () {
                  // Placeholder for login logic
                  // Add your authentication logic here

                  // Navigate to the home page after login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

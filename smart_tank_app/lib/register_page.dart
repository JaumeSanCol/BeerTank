// File: register_page.dart

import 'package:flutter/material.dart';
import 'package:smart_tank_app/dialog_utils.dart';
import 'package:smart_tank_app/login_page.dart';
import 'api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isRegistrationDataValid(BuildContext context, String email, String password) {
    // Validate email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      showErrorDialog(context, 'Invalid email format. Please enter a valid email.');
      return false;
    }

    // Validate password
    if (password.length < 8) {
      showErrorDialog(context, 'Password must be at least 8 characters long.');
      return false;
    }

    return true;
  }

  // Function to handle registration
  Future<void> register() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Check if the data is valid
    if (!isRegistrationDataValid(context, email, password)) {
      return;
    }

    // Prepare the request body
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'role': 'user', // Role is fixed as "user"
    };

    try {
      // Make the POST request using the ApiService class
      final response = await ApiService.postRequest("/register", body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        showSuccessDialog(context, 'Registration Successful! Please log in.');
      } else {
        showErrorDialog(context, 'Registration Failed - Please try again.');
      }
    } catch (e) {
      print("Error during registration: $e");
      showErrorDialog(context, 'Something went wrong! Try again later!');
    }
  }

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
                'Register',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40), // Space between title and fields
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20), // Space between fields
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20), // Space between fields
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40), // Space before the button
              ElevatedButton(
                onPressed: register, // Trigger registration
                child: const Text('Register'),
              ),
              const SizedBox(height: 10), // Space between buttons
              TextButton(
                onPressed: () {
                  // Navigate back to the Login Page
                  Navigator.pop(context);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

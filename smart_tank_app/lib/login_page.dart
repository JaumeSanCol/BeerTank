// File: login_page.dart

import 'package:flutter/material.dart';
import 'package:smart_tank_app/dialog_utils.dart';
import 'dart:convert';
import 'api_service.dart';
import 'main.dart';
import 'register_page.dart'; // Import RegisterPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to handle login
  Future<void> login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Prepare the request body
    final body = {
      'username': username,
      'password': password,
    };

    try {
      // Make the POST request using the ApiService class
      final response = await ApiService.postRequest("/login", body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Decode the response and retrieve the JWT token
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userId = data['UserId'];
        // Save the token to memory or a secure storage option
        ApiService.setTokens(accessToken, refreshToken, userId);

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        showErrorDialog(context, 'Login Failed - Please check your credentials');
      }
    } catch (e) {
      // Handle any errors during the request
      print("Error during login: $e");
      showErrorDialog(context, 'Something went wrong! Try again later!');
    }
  }

  @override
  void initState() {
    super.initState();
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
                'SmartTank',
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
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40), // Space before the buttons
              ElevatedButton(
                onPressed: login, // Trigger login
                child: const Text('Log In'),
              ),
              const SizedBox(height: 10), // Space between buttons
              TextButton(
                onPressed: () {
                  // Navigate to the Register Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

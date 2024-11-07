// File: login_page.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';  // Import the ApiService
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to handle login
  Future<void> login() async {
    final customerId = _customerIdController.text;
    final password = _passwordController.text;

    // Prepare the request body
    final body = {
      'username': customerId,
      'password': password,
    };

    try {
      // Make the POST request using the ApiService class
      final response = await ApiService.postRequest("/login", body);
      print(response.body);
      if (response.statusCode == 201) {
        // Decode the response and retrieve the JWT token
        final data = jsonDecode(response.body);
        final accessToken = data['accesstoken'];
        final refreshToken = data['refreshtoken'];

        // Save the token to memory or a secure storage option
        ApiService.setTokens(accessToken, refreshToken);

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        // Handle login failure
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Please check your credentials and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any errors during the request
      print("Error during login: $e");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
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
                controller: _customerIdController,
                decoration: const InputDecoration(
                  labelText: 'Customer ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                onPressed: login, // Trigger login without BuildContext
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

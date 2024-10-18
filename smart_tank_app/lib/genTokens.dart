// File: genTokens.dart

import 'package:flutter/material.dart';
import 'header.dart'; // Import the reusable header

class GenTokensPage extends StatefulWidget {
  const GenTokensPage({super.key});

  @override
  _GenTokensPageState createState() => _GenTokensPageState();
}

class _GenTokensPageState extends State<GenTokensPage> {
  final TextEditingController _customerIdController = TextEditingController();
  String _selectedEstablishment = 'Shop 1'; // Default selection
  int _tokenQuantity = 1;

  // List of predefined establishments
  final List<String> _establishments = ['Shop 1', 'Shop 2', 'Shop 3'];

  // Function to increase quantity
  void _incrementTokens() {
    setState(() {
      _tokenQuantity++;
    });
  }

  // Function to decrease quantity
  void _decrementTokens() {
    setState(() {
      if (_tokenQuantity > 1) {
        _tokenQuantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Generate Tokens'), // Reuse the header
      drawer: const HeaderDrawer(), // Reuse the drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Customer ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                hintText: 'Enter Customer ID',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Establishment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedEstablishment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEstablishment = newValue!;
                });
              },
              items: _establishments.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Token Quantity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementTokens,
                ),
                Text(
                  _tokenQuantity.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementTokens,
                ),
              ],
            ),
            const Spacer(), // Pushes the button to the bottom
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logic for generating tokens
                  // You can access the values using:
                  // _customerIdController.text, _selectedEstablishment, and _tokenQuantity
                },
                child: const Text('Generate Tokens'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

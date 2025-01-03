import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/establishment.dart';
import 'header.dart'; // Import the reusable header
import 'api_service.dart'; // Import the ApiService for API calls
import 'package:flutter/services.dart'; // For restricting input
import 'dialog_utils.dart'; // Import the dialog utility functions

class GenTokensPage extends StatefulWidget {
  const GenTokensPage({super.key});

  @override
  _GenTokensPageState createState() => _GenTokensPageState();
}

class _GenTokensPageState extends State<GenTokensPage> {
  final TextEditingController _customerIdController = TextEditingController();
  String? _selectedEstablishment; // Initially null until fetched
  int _tokenQuantity = 1;
  double _totalPrice = 0.00;

  Map<String, Establishment> _establishments = {}; // List to store establishments data

  @override
  void initState() {
    super.initState();
    _fetchEstablishments();
  }

  // Function to fetch establishments from the API
  Future<void> _fetchEstablishments() async {
    try {
      final response = await ApiService.getRequest('/info/establishments', requiresAuth: true);
      if (response.statusCode == 200) {
        // Parse the response and set up the establishments list
        final List<dynamic> data = jsonDecode(response.body); // Assuming response data is in JSON list format
        setState(() {
          for (var establishment in data) {
            _establishments[establishment['name']] = Establishment.fromJson(establishment);
          }
          if (_establishments.isNotEmpty) {
            _selectedEstablishment = _establishments.keys.first; // Set default selection
          }
        });
      } else if (response.statusCode == 403) {
        ApiService.refreshToken(context);
      } else {
        showErrorDialog(context, 'Failed to load establishments. Please try again.');
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while loading establishments.');
      print(e);
    }
    finally {
      setState(() {
        _totalPrice = _tokenQuantity * _establishments[_selectedEstablishment]!.price;
      });
    }
  }

  // Function to increase quantity
  void _incrementTokens() {
    setState(() {
      _tokenQuantity++;
      _totalPrice = _tokenQuantity * _establishments[_selectedEstablishment]!.price;
    });
  }

  // Function to decrease quantity
  void _decrementTokens() {
    setState(() {
      if (_tokenQuantity > 1) {
        _tokenQuantity--;
        _totalPrice = _tokenQuantity * _establishments[_selectedEstablishment]!.price;
      }
    });
  }

  // Function to handle the token generation logic
  Future<void> _generateTokens() async {
    final customerId = _customerIdController.text;

    // Check if establishments are loaded and the selected establishment is valid
    if (_establishments.isEmpty || _selectedEstablishment == null) {
      showErrorDialog(context, 'Please select a valid establishment.');
      return;
    }

    // Find the establishment by name
    final selectedEstablishment = _establishments[_selectedEstablishment];

    final establishmentID = selectedEstablishment?.id;
    print('selected: $selectedEstablishment');
    print('establishmentID = $establishmentID');
    // Ensure Customer ID is not empty
    if (customerId.isEmpty) {
      showErrorDialog(context, 'Customer ID cannot be empty');
      return;
    }

    final body = {
      'numberTokens': _tokenQuantity,
      'clientId': int.tryParse(customerId) ?? 0,
    };

    try {
      final response = await ApiService.postRequest(
        '/user/establishment/$establishmentID/tokens/create',
        body,
        requiresAuth: true,
      );
      if (response.statusCode == 201) {
        showSuccessDialog(context, 'Tokens generated successfully!');
      } else if (response.statusCode == 403) {
        ApiService.refreshToken(context);
      } else {
        showErrorDialog(context, 'Failed to generate tokens. Please try again.');
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred. Please try again later.');
      print(e);
    }
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
              controller: _customerIdController..text = ApiService.getUserId().toString(), // Set initial value
              keyboardType: TextInputType.number,
              inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ],
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
                  _totalPrice = _tokenQuantity * _establishments[newValue!]!.price;
                  _selectedEstablishment = newValue!;
                });
              },
              items: _establishments.keys.map<DropdownMenuItem<String>>((String value) {
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
            Text(
              'Price: ${_totalPrice.toStringAsFixed(2)}€',
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _generateTokens,
                child: const Text('Generate Tokens'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

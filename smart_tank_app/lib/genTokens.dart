import 'package:flutter/material.dart';
import 'header.dart'; // Import the reusable header
import 'api_service.dart'; // Import the ApiService for API calls
import 'package:flutter/services.dart'; // For restricting input

class GenTokensPage extends StatefulWidget {
  const GenTokensPage({super.key});

  @override
  _GenTokensPageState createState() => _GenTokensPageState();
}

class _GenTokensPageState extends State<GenTokensPage> {
  final TextEditingController _customerIdController = TextEditingController();
  String _selectedEstablishment = 'Shop 1'; // Default selection
  int _tokenQuantity = 1;

  // TODO this should be a list of all available establishments
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

  // Function to handle the token generation logic
  Future<void> _generateTokens() async {
    final customerId = _customerIdController.text;
    final establishment = _selectedEstablishment;
    final establishmentID = 3;  //TODO this should be the id of the selected establishment
    final tokenQuantity = _tokenQuantity;

    // Ensure Customer ID is not empty
    if (customerId.isEmpty) {
      _showErrorDialog('Customer ID cannot be empty');
      return;
    }

    // Call the API to generate tokens
    final body = {
      'numberTokens': tokenQuantity,
      'clientId': int.tryParse(customerId) ?? 0 // Convert customer ID to integer
    };

    try {
      final response = await ApiService.postRequest('/user/establishment/$establishmentID/tokens/create', body, requiresAuth: true);
      print(response.body);
      if (response.statusCode == 201) {
        // If the token generation is successful, show a success message
        _showSuccessDialog('Tokens generated successfully!');
      } else {
        // If the response is not successful, show an error message
        _showErrorDialog('Failed to generate tokens. Please try again.');
      }
    } catch (e) {
      // Handle any exceptions during the API request
      _showErrorDialog('An error occurred. Please try again later.');
      print(e);
    }
  }

  // Show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show a success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
              keyboardType: TextInputType.number, // Use numeric keyboard for customer ID
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
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
                onPressed: _generateTokens, // Call the function when the button is pressed
                child: const Text('Generate Tokens'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

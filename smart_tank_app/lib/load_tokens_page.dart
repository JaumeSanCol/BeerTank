// File: load_token_page.dart

import 'package:flutter/material.dart';
import 'package:smart_tank_app/token.dart';
import 'header.dart'; // Import the reusable header


class LoadTokenPage extends StatelessWidget {
  final List<Token> tokens;

  const LoadTokenPage({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Load Tokens to Cup'), // Reuse the header
      drawer: const HeaderDrawer(), // Reuse the drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Selected Tokens',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tokens.length,
                itemBuilder: (context, index) {
                  final token = tokens[index];
                  return ListTile(
                    title: Text('Token ID: ${token.id}'),
                    subtitle: Text('Establishment: ${token.establishmentId}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Set the button color to red
                    foregroundColor: Colors.white, // Set the text color to white
                  ),
                  onPressed: () {
                    // Placeholder for cancel logic
                    // Add your logic here
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // reveal a nfc icon and text field to scan the cup

                    // Placeholder for NFC logic
                    

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Scan Cup'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.nfc,
                                size: 50,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Place the cup on the NFC reader to load the tokens.',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                //TODO: Add logic to stop the NFC reader
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );

                  },
                  child: const Text('Load Tokens'),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
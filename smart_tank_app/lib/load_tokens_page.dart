// File: load_token_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/token.dart';
import 'header.dart'; // Import the reusable header


class LoadTokenPage extends StatefulWidget {
  final List<Token> tokens;
  const LoadTokenPage({super.key, required this.tokens});

  @override
  State<LoadTokenPage> createState() => _LoadTokenPageState();
}

class _LoadTokenPageState extends State<LoadTokenPage> {
  late AlertDialog _nfcDialog;
  late bool _nfcActive;

  void _showNfcDialog(context) {
    _nfcDialog = gettingNFCInitStatus(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _nfcDialog;
      },
    );

    _initNfc().then(
      (initStatus) {
        print('NFC init: $initStatus');
        Navigator.of(context).pop();
        
        if (initStatus) {
          _nfcDialog = successNFCInitDialog(context);
        } else {
          _nfcDialog = failureNFCInitDialog(context);
        }
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return _nfcDialog;
          },
        );
      
      if(!initStatus){
        return;
      }
      
      // Transfer data
      _transferData().then(
        (transferStatus) {
          Navigator.of(context).pop();
          print('Data transfer: $transferStatus');
          if (transferStatus) {
            _nfcDialog = successNFCWriteDialog(context);
          } else {
            _nfcDialog = failureNFCWriteDialog(context);
          }
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return _nfcDialog;
            },
          );
        },
      );
      }
    );
  }

  Future<bool> _initNfc() async {
    // Simulate NFC initialization
    await Future.delayed(Duration(seconds: 2));
    return true; // Return true if successful, false if failed
  }

  Future<bool> _transferData() async {
    // Simulate file transfer
    await Future.delayed(Duration(seconds: 2));
    return true; // Return true if successful, false if failed
  }

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
                itemCount: widget.tokens.length,
                itemBuilder: (context, index) {
                  final token = widget.tokens[index];
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
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => {
                    _showNfcDialog(context)
                  },
                  child: const Text('Load Tokens'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

AlertDialog successNFCInitDialog(BuildContext context) {
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
        },
        child: const Text('Close'),
      ),
    ],
  );
}

AlertDialog failureNFCInitDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('NFC Error'),
    content: const Text("Failed to initialize the NFC reader. Try enabling NFC in your device's settings."),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}

AlertDialog successNFCWriteDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Tokens Loaded'),
    content: const Text('The tokens have been successfully loaded to the cup.'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}

AlertDialog failureNFCWriteDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Failed to Load Tokens'),
    content: const Text('An error occurred while loading the tokens. Please try again.'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}

AlertDialog gettingNFCInitStatus(BuildContext context) {
  return AlertDialog(
    title: const Text('Initializing NFC'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Please wait...'),
      ],
    ),
  );
}
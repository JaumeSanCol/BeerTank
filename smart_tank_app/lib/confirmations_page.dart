import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smart_tank_app/dialog_utils.dart';
import 'confirmation.dart';
import 'header.dart'; // Import the reusable header
import 'api_service.dart'; // Import the ApiService for API calls

class ConfirmationsPage extends StatefulWidget {
  const ConfirmationsPage({super.key});

  @override
  _ConfirmationsPageState createState() => _ConfirmationsPageState();
}

class _ConfirmationsPageState extends State<ConfirmationsPage> {
  List<Confirmation> confirmationEntries = []; // List to hold fetched tokens
  Confirmation? selectedConfirmation;
  bool isLoading = true; // Indicator for loading state

  @override
  void initState() {
    super.initState();
    _fetchConfirmations(); 
  }

  

  Future<void> _fetchConfirmations() async {
    try {
      final response = await ApiService.getRequest('/confirmations/${ApiService.getUserId()}', requiresAuth: true);
      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        // Parse the response and set up the confirmations list
        final List<dynamic> data = jsonDecode(response.body); // Assuming response data is in JSON list format
        print(data);
        setState(() {
          confirmationEntries = Confirmation.fromJsonList(data);
        });
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, 'Failed to load confirmations');
          setState(() {
            confirmationEntries = [];
          });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorDialog(context, 'An error occurred while loading confirmations.');
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "Confirmations"),
      drawer: const HeaderDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    'Pending Confirmations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              confirmationEntries.isEmpty
                  ? Text(
                'No pending confirmations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: confirmationEntries.map((confirmation) {
                      return Card(
                        child: ListTile(
                          title: Text('Token: ${confirmation.token}'),
                          subtitle: Text('Establishment: ${confirmation.establishmentName}\n${confirmation.createdAt}'),
                          onTap: () {
                            setState(() {
                              selectedConfirmation = confirmation;
                            });
                          },
                          selected: selectedConfirmation == confirmation,
                          selectedTileColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              confirmationEntries.isEmpty || selectedConfirmation == null
                  ? const SizedBox()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Set the button color to red
                      foregroundColor: Colors.white, // Set the text color to white
                    ),
                    onPressed: () {
                      handleLogic(context, false);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleLogic(context, true);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  void handleLogic(BuildContext context, bool isConfirm) async{
    showDialog(
      context: context,
      builder: (context) {
        return waitingDialog(context);
      }
    );

    print("isConfirm $isConfirm");
    try {
      final response = await  ApiService.postRequest('/confirmations/confirm', {
        'confirmationId': selectedConfirmation!.id,
        'responseBinary': isConfirm ? 1 : 0
      }, requiresAuth: true);
      
      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return isConfirm ? successConfirmDialog(context) : successCancelDialog(context);
          }
        );
      } else {
        print("failure in response");
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return failureDialog(context);
          }
        );
      }
    } catch (e) {
      print("Error found");
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return failureDialog(context);
        }
      );
    }
  }

  AlertDialog waitingDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please Wait'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Please wait while we process your request.',
          ),
        ],
      ),
    );
  }

  AlertDialog failureDialog(BuildContext context){
    return AlertDialog(
      title: const Text('Failed to Confirm or Cancel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          const Text(
            'Failed to confirm or cancel the token use. Please try again.',
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

  AlertDialog successCancelDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Successfully Cancelled'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cancel,
            size: 50,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            'The token use was sucessfully cancelled.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
            confirmationEntries.remove(selectedConfirmation);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  AlertDialog successConfirmDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Successfully Confirmed'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          size: 50,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        const Text(
          'The token use was sucessfully confirmed.',
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();   
          setState(() {
            confirmationEntries.remove(selectedConfirmation);
            selectedConfirmation = null;
          });
        },
        child: const Text('Close'),
      ),
    ],
  );
}
}
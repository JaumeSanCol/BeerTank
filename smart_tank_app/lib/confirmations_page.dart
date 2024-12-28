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
    // try {
    //   //TODO: Replace 'PLACEHOLDER' with the actual API endpoint
    //   final response = await ApiService.getRequest('PLACEHOLDER', requiresAuth: true);
    //   if (response.statusCode == 200) {
    //     // Parse the response and set up the confirmations list
    //     final List<dynamic> data = jsonDecode(response.body); // Assuming response data is in JSON list format
    //     setState(() {
    //       confirmationEntries = data.map((entry) => Confirmation.fromJson(entry)).toList();
    //     });
    //   } else {
    //     showErrorDialog(context, 'Failed to load confirmations. Please try again.');
    //   }
    // } catch (e) {
    //   showErrorDialog(context, 'An error occurred while loading confirmations.');
    //   print(e);
    // } finally {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {
        confirmationEntries = [
          Confirmation(id:1, token: 1, userId: 1, establishmentName:"est1", usedAt:"03-02-2022"),
          Confirmation(id:2, token: 2, userId: 1, establishmentName:"est1", usedAt:"03-02-2022"),
          Confirmation(id:3, token: 3, userId: 1, establishmentName:"est1", usedAt:"03-02-2022"),
          Confirmation(id:4, token: 4, userId: 1, establishmentName:"est1", usedAt:"03-02-2022"),
        ];
        isLoading = false;
      });
    });
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
                          title: Text('Confirmation ID: ${confirmation.token}'),
                          subtitle: Text('Establishment: ${confirmation.establishmentName} at ${confirmation.usedAt}'),
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
              Row(
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
    if (isConfirm) {
      try {
      //TODO: Send API request to confirm the selected confirmation
        await ApiService.postRequest('PLACEHOLDER', {}, requiresAuth: true)
          .then((response) {
            if (response.statusCode == 200) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) {
                  return successConfirmDialog(context);
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
          });
      } catch (e) {
        print("Error found");
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return failureDialog(context);
          }
        );
      }
    } else {
      //TODO: Send API request to cancel the selected confirmation
      ApiService.postRequest('PLACEHOLDER', {}, requiresAuth: true).then((response) {
        if (response.statusCode == 200) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return successCancelDialog(context);
            }
          );
        } else {
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
      });
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
            color: Colors.red,
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
          Icons.nfc,
          size: 50,
          color: Colors.blue,
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
          confirmationEntries.remove(selectedConfirmation);       
        },
        child: const Text('Close'),
      ),
    ],
  );
}
}
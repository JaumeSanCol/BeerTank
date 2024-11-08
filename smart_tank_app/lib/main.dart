import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/load_tokens_page.dart';
import 'package:smart_tank_app/login_page.dart';
import 'header.dart';
import 'token.dart';
import 'api_service.dart'; // Import the ApiService for API calls
import 'dialog_utils.dart'; // Import dialog utility functions for error handling

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.white,
          onPrimary: Colors.amber,
          secondary: Colors.amber,
          onSecondary: Colors.amber,
          error: Colors.red,
          onError: Colors.white,
          surface: const Color(0xff261412),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Token> tokens = []; // List to hold fetched tokens
  Token? selectedToken;
  bool isLoading = true; // Indicator for loading state

  @override
  void initState() {
    super.initState();
    _fetchEstablishmentsAndTokens(); // Fetch establishments and tokens on init
  }

  // Fetch establishments and then tokens for each establishment
  Future<void> _fetchEstablishmentsAndTokens() async {
    try {
      // Fetch establishments
      final establishmentResponse = await ApiService.getRequest('/info/establishments', requiresAuth: true);
      if (establishmentResponse.statusCode == 200) {
        final List<dynamic> establishments = jsonDecode(establishmentResponse.body);

        // Iterate over each establishment and fetch tokens
        for (var establishment in establishments) {
          int establishmentId = establishment['id'];
          await _fetchTokensForEstablishment(establishmentId);
        }
      } else {
        showErrorDialog(context, 'Failed to load establishments');
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while loading establishments.');
      print(e);
    } finally {
      setState(() {
        isLoading = false; // End loading state
      });
    }
  }

  // Fetch tokens for a specific establishment and add to the tokens list
  Future<void> _fetchTokensForEstablishment(int establishmentId) async {
    try {
      final tokenResponse = await ApiService.getRequest('/user/establishment/$establishmentId', requiresAuth: true);
      if (tokenResponse.statusCode == 200) {
        final List<dynamic> establishmentTokens = jsonDecode(tokenResponse.body);
        print(establishmentTokens);
        setState(() {
          tokens.addAll(establishmentTokens.map((data) => Token(
            data['id'],
            establishmentId,
            data['UserId'],
            data['status'],
          )));
        });
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while fetching tokens.');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "SmartTank"),
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
                    'Active Tokens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              tokens.isEmpty
                  ? Text(
                'No tokens available, please buy one!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
              )
                  : LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.9,
                    child: Column(
                      children: tokens
                          .map((token) => token.establishmentId)
                          .toSet()
                          .map((establishmentId) {
                        List<Token> establishmentTokens = tokens
                            .where((token) => token.establishmentId == establishmentId)
                            .toList();
                        return ExpansionTile(
                          title: Text('Establishment $establishmentId'),
                          children: establishmentTokens.map((token) {
                            return ListTile(
                              title: Text('Token ${token.id}'),
                              subtitle: Text('Status: ${token.status}'),
                              onTap: () {
                                setState(() {
                                  selectedToken = selectedToken == token ? null : token;
                                });
                              },
                              selected: selectedToken == token,
                              selectedTileColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (selectedToken != null && selectedToken!.status == "phone") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadTokenPage(token: selectedToken!),
              ),
            );
          } else if (selectedToken != null && selectedToken!.status == "cup") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The token is already loaded to a cup. Please select another token')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a token first')),
            );
          }
        },
        label: const Text('Load to Cup', style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.local_drink, color: Colors.black),
        backgroundColor: Colors.amber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }


}

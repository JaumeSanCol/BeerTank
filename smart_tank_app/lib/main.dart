import 'package:flutter/material.dart';
import 'package:smart_tank_app/load_tokens_page.dart';
import 'header.dart';
import 'token.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.white,
          onPrimary: Colors.amber,
          secondary: Colors.amber,
          onSecondary: Colors.amber,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.grey.shade800,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber, // Background color
            foregroundColor: Colors.black
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The idea here is to load the tokens into this map from the server and keep track of the selection status
  // currently this has placeholder values
  //TODO: fetch real tokens from DB
  List<Token> tokens = [
    Token(1, 1, 1, "phone"),
    Token(2, 2, 1, "phone"),
    Token(3, 3, 1, "cup"),
    Token(4, 1, 1, "cup"),
    Token(5, 2, 1, "spent"),
  ];

  Token? selectedToken = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "SmartTank"),
      drawer: const HeaderDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Active Tokens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Using LayoutBuilder to dynamically fit the table into the screen
              LayoutBuilder(
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
                                if (selectedToken == token) {
                                selectedToken = null;
                                } else {
                                selectedToken = token;
                                }
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

              // Button at the end of the table
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic for button action
          if (selectedToken != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => LoadTokenPage(token: selectedToken!),
              ),
            );
          } else {
            // Handle the case when no token is selected
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a token first')),
            );
          }
        },
        label: const Text('Load to Cup', style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.local_drink, color: Colors.black,),
        backgroundColor: Colors.amber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
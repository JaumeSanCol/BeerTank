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
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  void _selectAll() {
    setState(() {
      tokenSelectionStatus.forEach((token, _) {
        tokenSelectionStatus[token] = true;
      });
    });
  }

  void _deselectAll() {
    setState(() {
      tokenSelectionStatus.forEach((token, _) {
        tokenSelectionStatus[token] = false;
      });
    });
  }

  // The idea here is to load the tokens into this map from the server and keep track of the selection status
  // currently this has placeholder values
  Map<Token, bool> tokenSelectionStatus = {
    Token('wa100', 'bar1', 'user1', true, false): false,
    Token('tf200', 'bar2', 'user1', false, false): false,
    Token('gh300', 'bar3', 'user1',false, true): false,
    Token('4gh00', 'bar1', 'user1', true, true): false,
    Token('50d0g', 'bar2', 'user1', false, false): false,
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "SmartTank"),
      drawer: const HeaderDrawer(),
      body: Center(
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
                if (tokenSelectionStatus.values.contains(true))
                  ElevatedButton(
                    onPressed: _deselectAll,
                    child: const Text('Deselect All'),
                  )
                else
                  ElevatedButton(
                    onPressed: _selectAll,
                    child: const Text('Select All'),
                  )
              ],
            ),
            // Using LayoutBuilder to dynamically fit the table into the screen
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  child: DataTable(
                    columnSpacing: 10, // Adjust this to fine-tune spacing
                    columns: const <DataColumn>[
                      DataColumn(label: Text('')), // Checkbox column
                      DataColumn(label: Text('Token')),
                      DataColumn(label: Text('Establishment')),
                      DataColumn(label: Text('Loaded to Cup?')),
                    ],
                    rows: tokenSelectionStatus.entries.map((entry) {
                      final token = entry.key;
                      final isSelected = entry.value;
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                tokenSelectionStatus[token] = value!;
                              });
                            },
                          )),
                          DataCell(Text(token.id)),
                          DataCell(Text(token.establishmentId)),
                          DataCell(Text(token.isLoaded ? 'Yes' : 'No')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Button at the end of the table
            ElevatedButton(
              onPressed: () {
                // Logic for button action

                // get selected tokens where value is true
                final selectedTokens = tokenSelectionStatus.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                
                //change to loading page
                if (selectedTokens.isEmpty) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadTokenPage(tokens: selectedTokens),
                  ),
                );
              },
              child: const Text('Load to Cup'),
            ),
          ],
        ),
      ),
    );
  }
}


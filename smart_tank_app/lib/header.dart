// File: header.dart

import 'package:flutter/material.dart';
import 'package:smart_tank_app/api_service.dart';
import 'login_page.dart';
import 'main.dart';
import 'genTokens.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      foregroundColor: Colors.black,
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeaderDrawer extends StatelessWidget {
  const HeaderDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: ListView(
              children: [
                Text(
                  'Smart Tank App',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'ID: ${ApiService.getUserId()}',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            )

          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('MyTokens'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.token), // Custom icon for token generation
            title: const Text('Generate Tokens'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenTokensPage()),
              );
            },
          ),
          const Divider(),
          // Add the Logout option
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

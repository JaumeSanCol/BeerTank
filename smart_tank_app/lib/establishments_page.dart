import 'package:flutter/material.dart';
import 'package:smart_tank_app/establishments_list.dart';
import 'header.dart'; // Import the reusable header

class EstablishmentPage extends StatefulWidget{
  const EstablishmentPage({super.key});

  @override
  State<StatefulWidget> createState() => _EstablishmentsPageState();

}

class _EstablishmentsPageState extends State<EstablishmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Establishments'), // Reuse the header
      drawer: const HeaderDrawer(), // Reuse the drawer
      body: EstablishmentList()
    );
  }

}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/tanks_list.dart';
import 'dialog_utils.dart';
import 'header.dart';
import 'mqtt_service.dart';
import 'api_service.dart';

class Establishment {
  final int id;
  final String name;
  final String address;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Establishment({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an Establishment from JSON
  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}


class EstablishmentPage extends StatefulWidget{
  const EstablishmentPage({super.key});

  @override
  State<StatefulWidget> createState() => _EstablishmentsPageState();

}

class _EstablishmentsPageState extends State<EstablishmentPage> {
  Establishment? selectedEstablishment;
  late Future<List<Establishment>> futureEstablishments;
  late MqttService mqttService;

  @override
  void initState() {
    super.initState();
    futureEstablishments = _fetchEstablishments();
    _initializeMqttService();
  }

  void _initializeMqttService() {
    mqttService = MqttService(
      broker: '95.94.45.83',
      port: 1883,
      username: 'pi',
      password: 'vfpYcu8BVUB26kgtk73sADxYVJ2O3URc62SWs80n',
      topics: ['temperature', 'water-level'],
    );

    mqttService.initializeMqtt().then((_) {
      print('MQTT Service Initialized');
    }).catchError((error) {
      print('Error initializing MQTT: $error');
    });
  }

  Future<List<Establishment>> _fetchEstablishments() async {
    try {
      // Fetch establishments
      final establishmentResponse = await ApiService.getRequest('/info/establishments', requiresAuth: true);
      if (establishmentResponse.statusCode == 200) {
        final List<dynamic> establishments = jsonDecode(establishmentResponse.body);
        return establishments.map((item) {
          return Establishment.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        showErrorDialog(context, 'Failed to fetch establishments');
        return List.empty();
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while fetching establishments.');
      print(e);
    }
    return List.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Establishments'),
      drawer: const HeaderDrawer(),
      body: Column(
        children: [
          FutureBuilder<List<Establishment>>(
            future: futureEstablishments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No establishments available'));
              }

              final establishments = snapshot.data!;

              if (selectedEstablishment == null && establishments.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    selectedEstablishment = establishments.first;
                  });
                });
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: DropdownButton<Establishment>(
                        hint: Text('Select an Establishment'),
                        value: selectedEstablishment,
                        isExpanded: true,
                        items: establishments.map((establishment) {
                          return DropdownMenuItem<Establishment>(
                            value: establishment,
                            child: Text(establishment.name),
                          );
                        }).toList(),
                        onChanged: (newEstablishment) {
                          setState(() {
                            selectedEstablishment = newEstablishment;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        print('Go to Add Establishment Page');
                      },
                      icon: Icon(Icons.add),
                      focusColor: Colors.amberAccent,
                    ),
                  ],
                )
              );
            },
          ),
          if (selectedEstablishment != null)
            Expanded(
              child: TankList(
                key: ValueKey(selectedEstablishment!.id),
                establishment: selectedEstablishment!,
                mqttService: mqttService,
              ),
            ),
        ],
      ),
    );
  }

}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/establishment_page.dart';
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


class EstablishmentsPage extends StatefulWidget{
  const EstablishmentsPage({super.key});

  @override
  State<StatefulWidget> createState() => _EstablishmentsPageState();

}

class _EstablishmentsPageState extends State<EstablishmentsPage> {
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: FutureBuilder<List<Establishment>>(
          future: futureEstablishments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No establishments available'));
            }

            final establishments = snapshot.data!;

            return ListView.builder(
              itemCount: establishments.length,
              itemBuilder: (context, index) {
                final establishment = establishments[index];

                return InkWell(
                  key: ValueKey(establishment.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstablishmentsPage(
                          establishment: establishment,
                          mqttService: mqttService,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          establishment.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Address: ${establishment.address}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          "Price: \$${establishment.price.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      )
    );
  }


}
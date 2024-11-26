import 'package:flutter/material.dart';
import 'package:smart_tank_app/tanks_list.dart';
import 'header.dart';
import 'mqtt_service.dart';

class Establishment {
  final int id;
  final String name;

  Establishment({required this.id, required this.name});

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
    );
  }
}

Future<List<Establishment>> fetchEstablishments() async {
  await Future.delayed(Duration(milliseconds: 500));
  return [
    Establishment(id: 1, name: "Bar 1"),
    Establishment(id: 2, name: "Bar 2"),
    Establishment(id: 3, name: "Bar 3"),
    Establishment(id: 4, name: "Bar 4"),
  ];
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
    futureEstablishments = fetchEstablishments();
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
              child: TankList(establishment: selectedEstablishment!, mqttService: mqttService),
            ),
        ],
      ),
    );
  }

}
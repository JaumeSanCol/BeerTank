import 'package:flutter/material.dart';
import 'package:smart_tank_app/mqtt_service.dart';
import 'package:smart_tank_app/stats_page.dart';
import 'establishments_page.dart';

class Tank {
  final int id;
  final String name;
  double level;
  final int beersServed;
  double temperature;

  Tank({
    required this.id,
    required this.name,
    required this.level,
    required this.beersServed,
    required this.temperature,
  });

  factory Tank.fromJson(Map<String, dynamic> json) {
    return Tank(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      beersServed: json['beersServed'],
      temperature: json['temperature'],
    );
  }
}

Future<List<Tank>> fetchTanks(int establishmentId) async {
  await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay

  return [
    Tank(id: 1, name: "BeerTank #1", level: 2.3, beersServed: 5, temperature: 7),
    Tank(id: 2, name: "BeerTank #2", level: establishmentId.toDouble(), beersServed: 10, temperature: 6),
  ];
}

class TankList extends StatefulWidget {
  final Establishment establishment;
  final MqttService mqttService;

  TankList({required this.establishment, required this.mqttService});

  @override
  _TankListState createState() => _TankListState();
}

class _TankListState extends State<TankList> {
  late List<Tank> tanks;
  late MqttService mqttService;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    mqttService = widget.mqttService;
    _fetchAndSetTanks();

    mqttService.messageStream.listen((message) {
      final String messageTankId = message['tankId'] ?? '';
      final String messageValue = message['value'] ?? '';
      final String messageTopic = message['topic'] ?? '';

      final int tankId = int.tryParse(messageTankId) ?? -1;
      final double parsedValue = double.tryParse(messageValue) ?? 0.0;

      setState(() {
        for (Tank tank in tanks) {
          if (tank.id == tankId) {
            if (messageTopic == 'temperature') {
              tank.temperature = parsedValue;
            } else if (messageTopic == 'water-level') {
              tank.level = parsedValue;
            }
          }
        }
      });
    });
  }

  Future<void> _fetchAndSetTanks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedTanks = await fetchTanks(widget.establishment.id);
      setState(() {
        tanks = fetchedTanks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching tanks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: tanks.length,
        itemBuilder: (context, index) {
          final tank = tanks[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsPage(tank: tank, mqttService: mqttService),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amberAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tank.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text("Level: ${tank.level.toStringAsFixed(1)} L", style: TextStyle(color: Colors.black)),
                  Text("Beers served: ${tank.beersServed}", style: TextStyle(color: Colors.black)),
                  Text("Temperature: ${tank.temperature.toStringAsFixed(1)}°C", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

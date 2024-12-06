import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_tank_app/mqtt_service.dart';
import 'package:smart_tank_app/statistics_page.dart';
import 'api_service.dart';
import 'dialog_utils.dart';
import 'establishments_page.dart';

class Tank {
  final int id;
  double level;
  final int beersServed;
  double temp;
  final int establishmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tank({
    required this.id,
    required this.level,
    required this.beersServed,
    required this.temp,
    required this.establishmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Tank from JSON
  factory Tank.fromJson(Map<String, dynamic> json) {
    return Tank(
      id: json['id'],
      level: (json['level'] as num).toDouble(),
      beersServed: json['beersServed'],
      temp: (json['temp'] as num).toDouble(),
      establishmentId: json['EstablishmentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class TankList extends StatefulWidget {
  final Establishment establishment;
  final MqttService mqttService;

  TankList({required ValueKey<int> key, required this.establishment, required this.mqttService});

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
    tanks = [];
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
              tank.temp = parsedValue;
            } else if (messageTopic == 'water-level') {
              tank.level = parsedValue;
            }
          }
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant TankList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.establishment.id != widget.establishment.id) {
      setState(() {
        tanks = [];
        _fetchAndSetTanks();
      });
    }
  }

  Future<void> _fetchAndSetTanks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedTanks = await _fetchTanksForEstablishment(widget.establishment.id);
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

  Future<List<Tank>> _fetchTanksForEstablishment(int establishmentId) async {
    try {
      final response = await ApiService.getRequest('/user/establishment/$establishmentId/tanks', requiresAuth: true);
      if (response.statusCode == 200) {
        final List<dynamic> tanks = jsonDecode(response.body);
        return tanks.map((item) {
          return Tank.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        showErrorDialog(context, 'Failed to fetch tanks');
        return List.empty();
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while fetching tanks.');
      print(e);
    }
    return List.empty();
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
            key: ValueKey(tank.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(tank: tank, mqttService: mqttService),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tank #${tank.id}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text("Level: ${tank.level.toStringAsFixed(1)} L", style: TextStyle(color: Colors.black)),
                  Text("Beers served: ${tank.beersServed}", style: TextStyle(color: Colors.black)),
                  Text("Temperature: ${tank.temp.toStringAsFixed(1)}°C", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_tank_app/statistics_page.dart';
import 'package:smart_tank_app/tanks_list.dart';
import 'dialog_utils.dart';
import 'establishments_page.dart';
import 'header.dart';
import 'mqtt_service.dart';
import 'api_service.dart';

class EstablishmentPage extends StatefulWidget {
  final Establishment establishment;
  final MqttService mqttService;

  const EstablishmentPage({super.key, required this.establishment, required this.mqttService});

  @override
  State<EstablishmentPage> createState() => _EstablishmentPageState();
}

class _EstablishmentPageState extends State<EstablishmentPage> {
  late Future<List<Tank>> futureTanks;
  int? totalBeersServed;
  int? tanksCounter;
  bool isLoadingInfo = false;

  @override
  void initState() {
    super.initState();
    _fetchEstablishmentInfo(widget.establishment.id);
    futureTanks = _fetchTanksForEstablishment(widget.establishment.id);
  }

  Future<List<Tank>> _fetchTanksForEstablishment(int establishmentId) async {
    try {
      final response = await ApiService.getRequest('/user/establishment/$establishmentId/tanks', requiresAuth: true);
      if (response.statusCode == 200) {
        final List<dynamic> tanks = jsonDecode(response.body);
        return tanks.map((item) => Tank.fromJson(item as Map<String, dynamic>)).toList();
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

  void _fetchEstablishmentInfo(int establishmentId) async {
    try {
      final response = await ApiService.getRequest('/statistics/establishment/$establishmentId', requiresAuth: true);
      if (response.statusCode == 200) {
        final Map<String, dynamic> infoResponse = jsonDecode(response.body);
        setState(() {
          totalBeersServed = infoResponse['totalBeerServed'];
          tanksCounter = infoResponse['tankCount'];
          isLoadingInfo = false;
        });
      } else {
        showErrorDialog(context, 'Failed to fetch establishment info');
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while fetching establishment info.');
      print(e);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, y h:mm a').format(timestamp); // e.g., Dec 5, 2024 2:45 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: 'Establishment Page'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.establishment.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Address: ${widget.establishment.address}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Price: \$${widget.establishment.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Created At: ${_formatTimestamp(widget.establishment.createdAt)}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (isLoadingInfo)
                  const Center(child: CircularProgressIndicator()) // Show loading indicator
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatsCard(
                        title: 'Tanks',
                        value: '${tanksCounter ?? 0}', // Use null-aware operator
                      ),
                      StatsCard(
                        title: 'Beers Served',
                        value: '${totalBeersServed ?? 0}', // Use null-aware operator
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tank>>(
              future: futureTanks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tanks available for this establishment.'));
                }

                return TankList(
                  key: ValueKey(widget.establishment.id),
                  establishment: widget.establishment,
                  mqttService: widget.mqttService,
                );
              },
            ),
          ),
        ],
      )
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_tank_app/header.dart';
import 'package:smart_tank_app/tanks_list.dart';

import 'api_service.dart';
import 'dialog_utils.dart';
import 'mqtt_service.dart';

class StatisticsPage extends StatefulWidget {
  final Tank tank;
  final MqttService mqttService;

  const StatisticsPage({super.key, required this.tank, required this.mqttService});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();

}

class _StatisticsPageState extends State<StatisticsPage> {
  late StreamSubscription _mqttSubscription;
  late StreamController<Map<String, dynamic>> _statsController;
  late Tank tank;

  bool _isLoading = true;

  late double temperature;
  late double level;

  final List<FlSpot> temperatureData = [];
  final List<FlSpot> levelData = [];
  final int maxDataPoints = 10;
  int elapsedTime = 0;

  @override
  void initState() {
    super.initState();

    _statsController = StreamController<Map<String, dynamic>>();

    tank = widget.tank;
    temperature = tank.temp;
    level = tank.level;

    // Listen for MQTT messages
    _mqttSubscription = widget.mqttService.messageStream.listen((message) {
      final String messageTankId = message['tankId'] ?? '';
      final String messageValue = message['value'] ?? '';
      final String messageTopic = message['topic'] ?? '';

      if (messageTankId == tank.id.toString()) {
        final double parsedValue = double.tryParse(messageValue) ?? 0.0;
        setState(() {
          if (messageTopic == 'temperature') {
            temperature = parsedValue;
          } else if (messageTopic == 'water-level') {
            level = parsedValue;
          }
        });
      }
    });

    _fetchData();
  }

  @override
  void dispose() {
    _mqttSubscription.cancel();
    _statsController.close();
    super.dispose();
  }

  Future<void> _fetchData() async {
    const tempString = 'temperature';
    const levelString = 'level';

    // Begin loading
    setState(() {
      _isLoading = true;
    });

    // fetch temperature values to FlSpots
    final temperatureValues = await _fetchTankLevelHistory(tempString, tank);
    final temperatureSpots = _parseDataToFlSpotTimestamp(tempString, temperatureValues);
    temperatureSpots.sort((a, b) => a.x.compareTo(b.x));

    // fetch level values to FlSpots
    final levelValues = await _fetchTankLevelHistory(levelString, tank);
    final levelSpots = _parseDataToFlSpotTimestamp(levelString, levelValues);
    levelSpots.sort((a, b) => a.x.compareTo(b.x));

    setState(() {
      temperatureData.addAll(temperatureSpots);
      if (temperatureData.length > 20) {
        temperatureData.removeRange(0, temperatureData.length - 20);
      }
      levelData.addAll(levelSpots);
      if (levelData.length > 20) {
        levelData.removeRange(0, levelData.length - 20);
      }
      // Data is loaded now
      _isLoading = false;
    });
  }

  Future<List> _fetchTankLevelHistory(String dataString, Tank tank) async {
    try {
      final establishmentResponse = await ApiService.getRequest(
          '/statistics/tank/${tank.id}/$dataString/history',
          requiresAuth: true
      );
      if (establishmentResponse.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(establishmentResponse.body);
        return responseData;
      } else {
        showErrorDialog(context, 'Failed to fetch tank level statistics history');
      }
    } catch (e) {
      showErrorDialog(context, 'An error occurred while fetching tank level statistics history');
      print(e);
    }
    return List.empty();
  }

  List<FlSpot> _parseDataToFlSpotTimestamp(String dataString, List<dynamic> data) {
    return data.map((entry) {
      final date = DateTime.parse(entry['datetime'] as String);
      final xValue = date.millisecondsSinceEpoch.toDouble();
      final yValue = (entry[dataString] as num).toDouble();
      return FlSpot(xValue, yValue);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: 'Statistics Page'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tank ${tank.id}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatsCard(
                  title: 'Temperature',
                  value: '$temperature ºC',
                ),
                StatsCard(
                  title: 'Level',
                  value: '$level L',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Temperature Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Only build the chart if we have data
            Expanded(
              child: temperatureData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      checkToShowTitle: (minValue, maxValue, sideTitles, appliedInterval, value) {
                        return temperatureData.any((spot) => spot.x == value);
                      },
                      reservedSize: 40,
                      interval: 3600000 * 4, // 3600000 ms = 1 hour
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      getTitles: (double value) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return DateFormat('HH:mm').format(date);
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      colors: [Colors.amberAccent],
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                      spots: temperatureData,
                    ),
                  ],
                  minY: 0,
                  maxY: 5,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          return LineTooltipItem(
                            'Temp: ${spot.y.toStringAsFixed(1)}ºC\nTime: ${DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              'Level Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: levelData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      checkToShowTitle: (minValue, maxValue, sideTitles, appliedInterval, value) {
                        return levelData.any((spot) => spot.x == value);
                      },
                      reservedSize: 40,
                      interval: 3600000 * 4, // 3600000 ms = 1 hour
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      getTitles: (double value) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return DateFormat('HH:mm').format(date);
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      colors: [Colors.amberAccent],
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                      spots: levelData,
                    ),
                  ],
                  minY: 0,
                  maxY: 3,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          return LineTooltipItem(
                            'Level: ${spot.y.toStringAsFixed(1)}L\nTime: ${DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;

  const StatsCard({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 150,
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_tank_app/header.dart';
import 'package:smart_tank_app/tanks_list.dart';

import 'mqtt_service.dart';

class StatsPage extends StatefulWidget {
  final Tank tank;
  final MqttService mqttService;

  const StatsPage({super.key, required this.tank, required this.mqttService});

  @override
  _StatsPageState createState() => _StatsPageState();

}

class _StatsPageState extends State<StatsPage> {
  late StreamSubscription _mqttSubscription;
  late StreamController<Map<String, dynamic>> _statsController;
  late Timer _mockTimer;
  late Tank tank;

  late double temperature;
  late double level;


  final List<FlSpot> temperatureData = [
    FlSpot(0, 0),
  ];

  final int maxDataPoints = 10;
  int elapsedTime = 0;

  @override
  void initState() {
    super.initState();

    _statsController = StreamController<Map<String, dynamic>>();

    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      var v = temperatureData.last.y < 0 ? temperatureData.last.y : temperatureData.last.y -1;
      final newTemperature = -v + 1;

      setState(() {
        elapsedTime += 2;
        temperatureData.add(FlSpot(elapsedTime.toDouble(), newTemperature.toDouble()));

        if (temperatureData.length > maxDataPoints) {
          temperatureData.removeAt(0);
        }
      });
    });

    tank = widget.tank;

    temperature = tank.temp;
    level = tank.level;

    _mqttSubscription = widget.mqttService.messageStream.listen((message) {
      final String messageTankId = message['tankId'] ?? '';
      final String messageValue = message['value'] ?? '';
      final String messageTopic = message['topic'] ?? '';

      // Check if the message is for this tank
      if (messageTankId == tank.id.toString()) {
        final double parsedValue = double.tryParse(messageValue) ?? 0.0;
        setState(() {
          // Update stats based on topic
          if (messageTopic == 'temperature') {
            temperature = parsedValue;
          } else if (messageTopic == 'water-level') {
            level = parsedValue;
          }
        });

        /*// Update the temperature graph if it's a temperature topic
        if (messageTopic == 'temperature') {
          setState(() {
            elapsedTime += 2;
            temperatureData.add(FlSpot(elapsedTime.toDouble(), temperature));

            if (temperatureData.length > maxDataPoints) {
              temperatureData.removeAt(0);
            }
          });
        }*/
      }
    });
  }

  @override
  void dispose() {
    _mockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: 'Statistics Page'),
      body: Padding(
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
            Expanded(
              child: LineChart(
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
                        getTextStyles: (value) => const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        getTitles: (value) => '${value.toInt()}s',
                        reservedSize: 22,
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
                        isCurved: true,
                        colors: [Colors.amberAccent],
                        barWidth: 4,
                        dotData: FlDotData(show: false),
                        spots: temperatureData,
                      ),
                    ],
                    minY: 0,
                    maxY: 15,
                    lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot spot) {
                                return LineTooltipItem(
                                    'Temp: ${spot.y.toStringAsFixed(1)}s\nTime: ${spot.x.toInt()}s',
                                    TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    )
                                );
                              }).toList();
                            }
                        )
                    )
                ),
              ),
            ),
            const Text(
              'Level Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
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
                        getTextStyles: (value) => const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        getTitles: (value) => '${value.toInt()}s',
                        reservedSize: 22,
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
                        isCurved: true,
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
                                    'Level: ${spot.y.toStringAsFixed(1)}l\nTime: ${spot.x.toInt()}s',
                                    TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    )
                                );
                              }).toList();
                            }
                        )
                    )
                ),
              ),
            )
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

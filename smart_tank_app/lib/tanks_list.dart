import 'package:flutter/material.dart';
import 'establishments_page.dart';

class Tank {
  final int id;
  final String name;
  final double level;
  final int beersServed;
  final double temperature;

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
  await Future.delayed(Duration(milliseconds: 500));

  return [
    Tank(id: 1, name: "BeerTank #1", level: 2.3, beersServed: 5, temperature: 7),
    Tank(id: 2, name: "BeerTank #2", level: establishmentId.toDouble(), beersServed: 10, temperature: 6),
  ];
}

class TankList extends StatefulWidget {
  final Establishment establishment;

  TankList({required this.establishment});

  @override
  _TankListState createState() => _TankListState();
}

class _TankListState extends State<TankList> {
  late Future<List<Tank>> futureTanks;

  @override
  void didUpdateWidget(covariant TankList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.establishment.id != widget.establishment.id) {
      setState(() {
        futureTanks = fetchTanks(widget.establishment.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureTanks = fetchTanks(widget.establishment.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Tank>>(
        future: futureTanks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tanks available'));
          }

          final tanks = snapshot.data!;

          return ListView.builder(
            itemCount: tanks.length,
            itemBuilder: (context, index) {
              final tank = tanks[index];

              return InkWell(
                onTap: () {
                  print('Clicked on tank: ${tank.name}');
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tank.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text("Level: ${tank.level} L"),
                      Text("Beers served: ${tank.beersServed}"),
                      Text("Temperature: ${tank.temperature}°C"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

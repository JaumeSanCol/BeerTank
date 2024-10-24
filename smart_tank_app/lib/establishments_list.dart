import 'package:flutter/material.dart';

class Establishment {
  final int id;
  final String name;
  final String address;

  Establishment({required this.id, required this.name, required this.address});

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

Future<List<Establishment>> fetchEstablishments() async {
  await Future.delayed(Duration(milliseconds: 500));
  return [
    Establishment(id: 1, name: "Bar 1", address: "rua 123"),
    Establishment(id: 2, name: "Bar 2", address: "rua 321"),
    Establishment(id: 3, name: "Bar 3", address: "rua 321"),
    Establishment(id: 4, name: "Bar 4", address: "rua 321"),
  ];
}


class EstablishmentList extends StatefulWidget {
  const EstablishmentList({super.key});

  @override
  _EstablishmentListState createState() => _EstablishmentListState();
}

class _EstablishmentListState extends State<EstablishmentList> {
  late Future<List<Establishment>> futureEstablishments;

  @override
  void initState() {
    super.initState();
    futureEstablishments = fetchEstablishments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Establishment>>(
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

          return ListView.builder(
            itemCount: establishments.length,
            itemBuilder: (context, index) {
              final establishment = establishments[index];

              return InkWell(
                onTap: () {
                  print('Clicked: ${establishment.name}');
                },
                child: ListTile(
                  title: Text(establishment.name),
                  subtitle: Text(establishment.address),
                  leading: Icon(Icons.store),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


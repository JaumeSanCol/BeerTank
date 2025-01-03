class Establishment {
  final int id;
  final String name;
  final String address;
  final double price;

  Establishment({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
  });

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      price: (json['price'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'price': price,
  };

  static List<Establishment> fromJsonList(List<dynamic> jsonList) {
    jsonList = jsonList.map((json) {
      json['price'] = (json['price'] as num).toDouble();
      return json;
    }).toList();
    return jsonList.map((json) => Establishment.fromJson(json)).toList();
  }
}
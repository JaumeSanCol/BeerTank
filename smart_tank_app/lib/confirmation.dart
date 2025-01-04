class Confirmation {
  final int id;
  final int token;
  final int userId;
  final String establishmentName;
  final String createdAt;

  Confirmation({
    required this.id,
    required this.token,
    required this.userId,
    required this.establishmentName,
    required this.createdAt,
  });

  factory Confirmation.fromJson(Map<String, dynamic> json) {
    return Confirmation(
      id: json['id'],
      token: json['tokenId'],
      userId: json['userId'],
      establishmentName: json['establishmentName'],
      createdAt: json['createdAt'].toString().replaceAll('T', ' ').replaceAll('Z', ' ').split('.').first.substring(0, 19),
    );
  }

  static List<Confirmation> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((data) => Confirmation.fromJson(data)).toList();
  }
}
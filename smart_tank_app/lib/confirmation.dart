class Confirmation {
  final int id;
  final int token;
  final int userId;
  final String establishmentName;
  final String usedAt;

  Confirmation({
    required this.id,
    required this.token,
    required this.userId,
    required this.establishmentName,
    required this.usedAt,
  });

  factory Confirmation.fromJson(Map<String, dynamic> json) {
    return Confirmation(
      id: json['id'],
      token: json['token'],
      userId: json['userId'],
      establishmentName: json['establishmentName'],
      usedAt: json['usedAt'],
    );
  }

  static List<Confirmation> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((data) => Confirmation.fromJson(data)).toList();
  }
}
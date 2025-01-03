class Token {
  final int id;
  final int establishmentId;
  final int userID;
  String status; //phone, cup, spent

  Token(this.id, this.establishmentId, this.userID, this.status);

  Token.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        establishmentId = json['establishmentId'],
        userID = json['userID'],
        status = json['status'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'establishmentId': establishmentId,
    'userID': userID,
    'status': status
  };

  bool spendToken() {
    if (status == 'spent'){
      throw Exception('Token is already spent');
    }
    status = 'spent';
    return true;
  }

  bool loadTokenToCup() {
    //TODO: should connect to the server to update the status of the token

    if (status == 'cup'){
      throw Exception('Token is already loaded to a cup');
    }
    if (status == 'spent'){
      throw Exception('Token is already spent');
    }
    status = 'cup';
    return true;
  }
}


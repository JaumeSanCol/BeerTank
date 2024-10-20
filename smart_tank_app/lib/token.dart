/// A class representing a Token with an ID, establishment ID, active status, and loaded to cup status.
/// 
/// The [Token] class provides methods to toggle the active and loaded status, 
/// and to serialize and deserialize the token from JSON.
/// 
/// Properties:
/// - `id`: The unique identifier for the token.
/// - `establishmentId`: The identifier for the establishment associated with the token.
/// - `isActive`: A boolean indicating whether the token is active.
/// - `isLoaded`: A boolean indicating whether the token is loaded to a cup.
class Token {
  final String id;
  final String establishmentId;
  final String customerId;
  bool isActive;
  bool isLoaded;

  /// Creates a new Token with the given ID, establishment ID, active status, and loaded status.
  Token(this.id, this.establishmentId, this.customerId, this.isActive, this.isLoaded);

  Token.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        establishmentId = json['establishmentId'],
        customerId = json['customerId'],
        isActive = json['isActive'],
        isLoaded = json['isLoaded'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'establishmentId': establishmentId,
    'customerId': customerId,
    'isActive': isActive,
    'isLoaded': isLoaded,
  };

  /// Toggles the state of the `isActive` variable.
  /// 
  /// This method switches the value of `isActive` from `true` to `false` or 
  /// from `false` to `true`, and then returns the new value of `isActive`.
  /// 
  /// Returns:
  ///   - `bool`: The new state of the `isActive` variable.
  bool toggleActive() {
    //TODO: should connect to the server to update the status of the token

    isActive = !isActive;
    return isActive;
  }

  /// Toggles the state of the `isLoaded` variable.
  /// 
  /// This method switches the value of `isLoaded` from `true` to `false` or 
  /// from `false` to `true`, and then returns the new value of `isLoaded`.
  /// 
  /// Returns:
  ///   - `bool`: The new state of the `isLoaded` variable.
  bool toggleLoaded() {
    //TODO: should connect to the server to update the status of the token

    isLoaded = !isLoaded;
    return isLoaded;
  }
}


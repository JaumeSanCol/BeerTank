import 'dart:convert';
import 'package:flutter/services.dart';  // To load the config.json
import 'package:http/http.dart' as http;

// Class to manage API interactions
class ApiService {
  // Variable to hold the base URL
  static String _baseUrl = '';

  // Variable to hold the JWT token
  static String? _jwtToken;
  static String? _refreshToken;

  // Function to load configuration from the JSON file (base_url)
  static Future<void> loadConfig() async {
    try {
      // Load the config file from assets
      final String response = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> config = jsonDecode(response);
      _baseUrl = config['base_url']; // Set the base URL from the config file
    } catch (e) {
      print("Error loading config: $e");
    }
  }

  // Function to set the JWT token (can be called after login)
  static void _setJwtToken(String token) {
    _jwtToken = token;
  }

  // Function to get the JWT token (for use in requests)
  static String? _getJwtToken() {
    return _jwtToken;
  }

  // Function to set the JWT token (can be called after login)
  static void _setRefreshToken(String token) {
    _refreshToken = token;
  }

  // Function to get the JWT token (for use in requests)
  static String? _getRefreshToken() {
    return _refreshToken;
  }

  // Function to make a POST request
  static Future<http.Response> postRequest(
      String endpoint,
      Map<String, dynamic> body, {
        bool requiresAuth = false,
      }) async {
    await loadConfig();

    final url = Uri.parse("$_baseUrl$endpoint");

    // Build the headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // If the request requires authentication, add the Authorization header
    if (requiresAuth && _jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  // Function to make a GET request
  static Future<http.Response> getRequest(
      String endpoint, {
        bool requiresAuth = false,
      }) async {
    await loadConfig();

    final url = Uri.parse("$_baseUrl$endpoint");

    // Build the headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // If the request requires authentication, add the Authorization header
    if (requiresAuth && _jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }

    final response = await http.get(
      url,
      headers: headers,
    );
    return response;
  }

  static void setTokens(accessToken, refreshToken) {
    _setJwtToken(accessToken);
    _setRefreshToken(refreshToken);
  }
}

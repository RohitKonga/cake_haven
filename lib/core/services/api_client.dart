import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, this.getToken});

  final String baseUrl;
  final Future<String?> Function()? getToken;

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (getToken != null) {
      final token = await getToken!();
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}



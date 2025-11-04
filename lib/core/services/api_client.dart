import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, this.getToken});

  final String baseUrl;
  final Future<String?> Function()? getToken;

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await buildHeaders();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await buildHeaders();
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await buildHeaders();
    return http.patch(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await buildHeaders();
    return http.delete(uri, headers: headers);
  }

  Future<Map<String, String>> buildHeaders({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (getToken != null) {
      final token = await getToken!();
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}



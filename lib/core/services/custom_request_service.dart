import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class CustomRequestService {
  CustomRequestService(this.client);
  final ApiClient client;

  Future<String> create({required String shape, required String flavor, required String weight, String? theme, String? message}) async {
    final res = await client.post('/api/custom', {
      'shape': shape,
      'flavor': flavor,
      'weight': weight,
      'theme': theme,
      'message': message,
    });
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['id'] as String?) ?? (data['_id'] as String);
  }

  Future<String?> uploadImage({required String requestId, required List<int> bytes, required String filename}) async {
    final uri = Uri.parse('${client.baseUrl}/api/custom/$requestId/image');
    final headers = await client.buildHeaders(json: false);
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(headers);
    req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['imageUrl'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final res = await client.get('/api/custom/me');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
  }
}

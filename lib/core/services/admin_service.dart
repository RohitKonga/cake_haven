import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AdminService {
  AdminService(this.client);
  final ApiClient client;

  Future<List<dynamic>> listOrders() async {
    final res = await client.get('/api/orders');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final res = await client.patch('/api/orders/' + id + '/status', { 'status': status });
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listCakes() async {
    final res = await client.get('/api/cakes');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCake(Map<String, dynamic> cake) async {
    final res = await client.post('/api/cakes', cake);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCake(String id, Map<String, dynamic> cake) async {
    final res = await client.patch('/api/cakes/' + id, cake);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<String?> uploadCakeImage(String id, List<int> bytes, String filename) async {
    final uri = Uri.parse(client.baseUrl + '/api/cakes/' + id + '/image');
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

  Future<bool> deleteCake(String id) async {
    final res = await client.delete('/api/cakes/' + id);
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<List<dynamic>> listCustomRequests() async {
    final res = await client.get('/api/custom');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> listUsers() async {
    final res = await client.get('/api/admin/users');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> reviewCustom(String id, String status, {double? price}) async {
    final body = { 'status': status, if (price != null) 'customPrice': price };
    final res = await client.patch('/api/custom/' + id + '/review', body);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}



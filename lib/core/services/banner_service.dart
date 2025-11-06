import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class BannerService {
  BannerService(this.client);
  final ApiClient client;

  Future<List<Map<String, dynamic>>> getBanners() async {
    final res = await client.get('/api/banners');
    return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
  }
}


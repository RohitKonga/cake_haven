import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/cake.dart';
import 'api_client.dart';

class CakeService {
  CakeService(this.client);
  final ApiClient client;

  Future<List<Cake>> listCakes() async {
    try {
      final res = await client.get('/api/cakes');
      
      if (kDebugMode) {
        print('📡 API Response Status: ${res.statusCode}');
        print('📡 API Response Body: ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}');
      }
      
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Failed to load cakes: HTTP ${res.statusCode} - ${res.body}');
      }
      
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Cake.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in listCakes: $e');
      }
      rethrow;
    }
  }
}



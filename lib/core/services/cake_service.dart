import 'dart:convert';
import '../models/cake.dart';
import 'api_client.dart';

class CakeService {
  CakeService(this.client);
  final ApiClient client;

  Future<List<Cake>> listCakes() async {
    final res = await client.get('/api/cakes');
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Cake.fromJson(e as Map<String, dynamic>)).toList();
  }
}



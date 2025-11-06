import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this.client);
  final ApiClient client;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<(String token, AppUser user)> signup(String name, String email, String password, {String? phone}) async {
    final body = {'name': name, 'email': email, 'password': password};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    
    final res = await client.post('/api/auth/signup', body);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await saveToken(token);
    return (token, user);
  }

  Future<(String token, AppUser user)> login(String email, String password) async {
    final res = await client.post('/api/auth/login', { 'email': email, 'password': password });
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await saveToken(token);
    return (token, user);
  }

  Future<AppUser> getMe() async {
    final res = await client.get('/api/auth/me');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return AppUser.fromJson(data);
    } else {
      throw Exception('Failed to get user: ${res.body}');
    }
  }

  Future<AppUser> updateProfile(Map<String, dynamic> updates) async {
    final res = await client.patch('/api/auth/profile', updates);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return AppUser.fromJson(data);
    } else {
      throw Exception('Failed to update profile: ${res.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final res = await client.get('/api/auth/addresses');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['addresses'] ?? []);
    } else {
      throw Exception('Failed to get addresses: ${res.body}');
    }
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    final res = await client.post('/api/auth/addresses', address);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to add address: ${res.body}');
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> address) async {
    final res = await client.patch('/api/auth/addresses/$id', address);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update address: ${res.body}');
    }
  }

  Future<void> deleteAddress(String id) async {
    final res = await client.delete('/api/auth/addresses/$id');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to delete address: ${res.body}');
    }
  }
}



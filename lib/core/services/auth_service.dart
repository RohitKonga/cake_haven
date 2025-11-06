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

  Future<(String token, AppUser user)> signup(String name, String email, String password) async {
    final res = await client.post('/api/auth/signup', { 'name': name, 'email': email, 'password': password });
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

  Future<AppUser> updateProfile(Map<String, dynamic> updates) async {
    final res = await client.patch('/api/auth/profile', updates);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final res = await client.get('/api/auth/addresses');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['addresses'] ?? []);
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    await client.post('/api/auth/addresses', address);
  }

  Future<void> updateAddress(String id, Map<String, dynamic> address) async {
    await client.patch('/api/auth/addresses/$id', address);
  }

  Future<void> deleteAddress(String id) async {
    await client.delete('/api/auth/addresses/$id');
  }
}



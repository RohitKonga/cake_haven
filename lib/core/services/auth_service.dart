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
}



import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _loadUser();
  }

  final AuthService _authService;
  AuthService? _authedAuthService;
  AppUser? currentUser;
  String? token;
  bool isLoading = false;
  String? error;

  AuthService get _serviceForProfile => _authedAuthService ?? _authService;

  Future<void> _loadUser() async {
    final savedToken = await _authService.getToken();
    if (savedToken != null) {
      token = savedToken;
      // Wait for authed client to be set (it's set in main.dart)
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        // Use authed service if available, otherwise use regular service
        final service = _authedAuthService ?? _authService;
        final user = await service.getMe();
        currentUser = user;
        notifyListeners();
      } catch (e) {
        // Token might be invalid, clear it
        await _authService.clearToken();
        token = null;
      }
    }
  }

  Future<void> signup(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final (t, u) = await _authService.signup(name, email, password);
      token = t;
      currentUser = u;
      // Update authed service after successful signup
      if (_authedAuthService == null && _authService.client.getToken != null) {
        _authedAuthService = AuthService(_authService.client);
      }
    } catch (e) {
      error = 'Signup failed: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final (t, u) = await _authService.login(email, password);
      token = t;
      currentUser = u;
      // Update authed service after successful login
      if (_authedAuthService == null && _authService.client.getToken != null) {
        _authedAuthService = AuthService(_authService.client);
      }
    } catch (e) {
      error = 'Login failed';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setAuthedClient(ApiClient client) {
    _authedAuthService = AuthService(client);
  }

  Future<void> logout() async {
    await _authService.clearToken();
    currentUser = null;
    token = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updated = await _serviceForProfile.updateProfile(updates);
      currentUser = updated;
      notifyListeners();
    } catch (e) {
      error = 'Update failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    return await _serviceForProfile.getAddresses();
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    await _serviceForProfile.addAddress(address);
  }

  Future<void> deleteAddress(String id) async {
    await _serviceForProfile.deleteAddress(id);
  }
}



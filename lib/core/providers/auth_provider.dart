import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  AppUser? currentUser;
  String? token;
  bool isLoading = false;
  String? error;

  Future<void> signup(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final (t, u) = await _authService.signup(name, email, password);
      token = t;
      currentUser = u;
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
    } catch (e) {
      error = 'Login failed';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    currentUser = null;
    token = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updated = await _authService.updateProfile(updates);
      currentUser = updated;
      notifyListeners();
    } catch (e) {
      error = 'Update failed: $e';
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    return await _authService.getAddresses();
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    await _authService.addAddress(address);
  }

  Future<void> deleteAddress(String id) async {
    await _authService.deleteAddress(id);
  }
}



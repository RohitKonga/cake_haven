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
}



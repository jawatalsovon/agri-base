import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // Reload user to get latest data including displayName
      _user = _authService.currentUser;
      if (_user != null) {
        await _user!.reload();
        _user = _authService.currentUser;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Handle AuthException and other exceptions
      if (e is AuthException) {
        return e.message;
      } else {
        return e.toString().replaceAll('Exception: ', '');
      }
    }
  }

  Future<String?> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.createUserWithEmailAndPassword(email, password, username);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Handle AuthException and other exceptions
      if (e is AuthException) {
        return e.message;
      } else {
        return e.toString().replaceAll('Exception: ', '');
      }
    }
  }

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      // Reload user to get latest data including displayName
      _user = _authService.currentUser;
      if (_user != null) {
        await _user!.reload();
        _user = _authService.currentUser;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Handle AuthException and other exceptions
      if (e is AuthException) {
        return e.message;
      } else {
        return e.toString().replaceAll('Exception: ', '');
      }
    }
  }

  // Get username from user
  String? get username {
    if (_user == null) return null;
    // Try displayName first, then email prefix, then just "User"
    return _user!.displayName?.isNotEmpty == true
        ? _user!.displayName
        : (_user!.email != null ? _user!.email!.split('@')[0] : 'User');
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

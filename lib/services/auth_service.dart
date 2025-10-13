import 'dart:async';

class AuthService {
  Future<bool> isUserLoggedIn() async {
    // 🔹 TODO: Check actual login status from backend/auth provider
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // For now, always logged in
  }
}

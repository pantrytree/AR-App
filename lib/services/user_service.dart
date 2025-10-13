import 'dart:async';

class UserService {
  Future<String> getUserName() async {
    // 🔹 TODO: Fetch actual user data from backend
    await Future.delayed(const Duration(milliseconds: 500));
    return "MockUser";
  }
}

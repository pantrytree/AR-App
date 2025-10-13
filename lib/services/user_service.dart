class UserService {
  Future<String> getCurrentUserName() async {
    // TODO: Backend - Implement actual user service
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return "Bulelwa"; // Mock data
  }
}
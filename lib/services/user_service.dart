class UserService {
  // Backend team will implement real API call
  Future<String> getCurrentUserName() async {
    await Future.delayed(Duration(seconds: 1)); // Simulates API delay
    return "userName"; // Placeholder data - backend will replace with dynamic data
  }

  // Backend team will implement real API call
  Future<Map<String, dynamic>> getUserProfile() async {
    return {
      "displayName": "Guest User", // Placeholder data
      "email": "guest@example.com", // Placeholder data
      "profileImage": null, // Placeholder data
    };
  }
}
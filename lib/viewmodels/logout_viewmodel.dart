import 'package:flutter/foundation.dart';

class LogoutViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();

    // Simulate logout process
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();

    // Navigation will be handled by the page
  }
}
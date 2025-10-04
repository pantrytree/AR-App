import 'package:flutter/material.dart';

class EditProfileViewModel extends ChangeNotifier {
  // Form fields
  String _name = '';
  String _email = '';
  String _username = '';
  String _password = '';

  //  Password visibility state
  bool _obscurePassword = true;

  // Getters
  String get name => _name;
  String get email => _email;
  String get username => _username;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;

  // Setters with notification
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }


  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }


  Future<void> saveProfile() async {
    // TODO: Add validation & API call here
    print('Saving profile...');
    print('Name: $_name, Email: $_email, Username: $_username, Password: $_password');
  }
}


import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  int? userId;
  String? username;
  String? role;
  // String? fotoProfilUrl;

  bool get isLoggedIn => userId != null;

  void login(int id, String newUsername, String userRole) {
    userId = id;
    username = newUsername;
    role = userRole;
    // fotoProfilUrl = fotoUrl ?? "";
    notifyListeners();
  }

  void logout() {
    userId = null;
    username = null;
    role = null;
    // fotoProfilUrl = null;
    notifyListeners();
  }

  void updateUsername(String newUsername) {
    username = newUsername;
    notifyListeners();
  }

  // void updateFotoProfil(String url) {
  //   fotoProfilUrl = url;
  //   notifyListeners();
  // }
}
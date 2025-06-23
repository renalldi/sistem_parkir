import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';
  static const _secureStorage = FlutterSecureStorage();

  /// Simpan token dan role (bisa dipanggil langsung pas login)
  static Future<void> saveTokenAndRole({
    required String token,
    required String role,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_roleKey, role);

      // ✅ Tambahkan log untuk web
      print('[TokenStorage - Web] Token disimpan: $token');
      print('[TokenStorage - Web] Role disimpan: $role');
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _roleKey, value: role);

      // ✅ Tambahkan log untuk mobile
      print('[TokenStorage - Mobile] Token disimpan: $token');
      print('[TokenStorage - Mobile] Role disimpan: $role');
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken(); // gunakan fungsi getToken yang sudah dibuat

    if (token == null) throw Exception("Token tidak ditemukan");

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  /// Simpan token saja
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  /// Simpan role saja
  static Future<void> saveRole(String role) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role);
    } else {
      await _secureStorage.write(key: _roleKey, value: role);
    }
  }

  /// Ambil token
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  /// Ambil role
  static Future<String?> getRole() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } else {
      return await _secureStorage.read(key: _roleKey);
    }
  }

  /// Hapus semua token + role
  static Future<void> deleteAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_roleKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _roleKey);
    }
  }
}
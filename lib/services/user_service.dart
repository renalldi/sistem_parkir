import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class UserService {
  static const String baseUrl = 'https://fasparkbe-production.up.railway.app'; 

  // Register
  static Future<Map<String, dynamic>> register(String username, String password, String role) async {
    final url = Uri.parse('$baseUrl/api/userauth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

        // DEBUGGING
      print('UserService Login Status Code: ${response.statusCode}');
      print('Login Response Headers: ${response.headers}');
      print('UserService Login Response Body: ${response.body}');
      

      if (response.statusCode == 307) { 
        String? newLocation = response.headers['location']; 
        print('Server mengarahkan ke: $newLocation');
        return {
          'success': false,
          'message': 'Server meminta redirect ke $newLocation (Status: 307). Perlu penyesuaian URL atau server.',
        };
      }
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Error: Respons dari server kosong (Status: ${response.statusCode})',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi sukses',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/userauth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: '${response.body}'");

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Respons kosong dari server (status: ${response.statusCode})',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final role = data['role'] ?? data['user']?['role'] ?? 'User';

        await TokenStorage.saveTokenAndRole(token: token, role: role);
        print("Token saved: $token");
        print("Role saved: $role");

        return {
          'success': true,
          'user': data['user'],
          'token': token,
          'role': role,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Tambahan opsional: ambil token, role, dan logout
  static Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  static Future<String?> getRole() async {
    return await TokenStorage.getRole();
  }

  static Future<void> logout() async {
    await TokenStorage.deleteAll();
  }

  // update profil
  static Future<Map<String, dynamic>> updateProfile(String id, String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/userauth/update-profile/$id');
      final body = <String, dynamic>{
        'username': username,
      };

      if (password.isNotEmpty) {
        body['password'] = password;
      }
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          if (password.isNotEmpty) 'password': password,
        }),
      );

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Respons kosong dari server (status ${response.statusCode})',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Berhasil'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan: $e',
      };
    }
  }
}

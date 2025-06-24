import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthService {
  static const String baseUrl = 'https://fasparkbe-production.up.railway.app';

  // ✅ Login dan simpan token + role
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

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

      if (response.statusCode == 200) {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

        if (body != null && body['token'] != null) {
          final token = body['token'];
          String? role;

          // Ambil role dari body
          if (body['role'] != null) {
            role = body['role'];
          } else {
            role = _extractRoleFromToken(token);
          }

          await TokenStorage.saveTokenAndRole(token: token, role: role ?? "Unknown");

          return {
            'success': true,
            'token': token,
            'role': role,
          };
        } else {
          return {
            'success': false,
            'message': 'Token tidak ditemukan dalam respons.',
          };
        }
      } else {
        // 🔧 Tambahan: amankan parsing body error
        String message = 'Login gagal.';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            message = errorBody['message'] ?? message;
          }
        } catch (e) {
          print("Gagal parsing error response: $e");
        }

        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ✅ Decode role dari payload JWT
  static String? _extractRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = json.decode(
        utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        ),
      );

      return payload['role'] ?? payload['roles']?.first;
    } catch (e) {
      return null;
    }
  }

  // ✅ Ambil token
  static Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  // ✅ Ambil role
  static Future<String?> getRole() async {
    return await TokenStorage.getRole();
  }

  // ✅ Logout = hapus token dan role
  static Future<void> logout() async {
    await TokenStorage.deleteAll();
  }

  // ✅ Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }

  // ✅ GET dengan auth
  static Future<http.Response> getProtected(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // ✅ POST dengan auth
  static Future<http.Response> postWithAuth(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  // ✅ PUT dengan auth
  static Future<http.Response> putWithAuth(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  // ✅ DELETE dengan auth
  static Future<http.Response> deleteWithAuth(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // ✅ Cek 401
  static bool isUnauthorized(http.Response response) {
    return response.statusCode == 401;
  }

}
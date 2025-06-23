import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ParkingService {
  static const String baseUrl = 'https://localhost:7211';

  Future<List<dynamic>> fetchParkingStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/parkir/area-status'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data parkir');
    }
  }

  Future<int> parkirMasuk(int userId, int areaId) async {
    final token = await TokenStorage.getToken(); // Ambil JWT token dari storage

    final response = await http.post(
      Uri.parse('$baseUrl/api/parkir'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Sertakan token di header
      },
      body: jsonEncode({
        'id_User': userId,
        'id_Area': areaId,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['message'] ?? 'Gagal parkir');
    }

    print("Response → ${response.body}");

    return json.decode(response.body)['id'];
  }



  Future<void> parkirKeluar(int riwayatId) async {
    try {
      final headers = await TokenStorage.getAuthHeaders(); // ✅ ambil token dulu
      final response = await http.put(
        Uri.parse('$baseUrl/api/parkir/$riwayatId'),
        headers: headers, // ✅ tambahkan ini
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Keluar parkir: ${data['message']}');
      } else {
        print('❌ Gagal keluar: Status ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Keluar parkir gagal: ${response.body}');
      }
    } catch (e) {
      print('❌ Gagal keluar: $e');
    }
  }
} 
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart'; // import AuthService
import '../models/lost_item_model.dart';

class LostItemService {
  static const String baseUrl = 'https://192.168.111.40:7211'; // ganti ke IP HP kalau test di device

  // ✅ Submit laporan kehilangan (dengan ambil token otomatis)
  static Future<bool> submitLostItemReport(LostItemReport report) async {
    final token = await AuthService.getToken();
    if (token == null) {
      print('❌ Gagal kirim laporan: token tidak ditemukan.');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/Record');
    var request = http.MultipartRequest('POST', url);

    // Tambah header untuk JWT
    request.headers['Authorization'] = 'Bearer $token';

    // Tambah field (pakai snake_case sesuai backend)
    request.fields.addAll(report.toJson());

    // Upload foto jika tersedia
    if (report.foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', report.foto!.path),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Berhasil kirim laporan kehilangan.");
        return true;
      } else {
        print("❌ Gagal kirim laporan: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🔥 Error saat mengirim laporan: $e");
      return false;
    }
  }

  // ✅ Wrapper mudah untuk dipakai di UI (tanpa token manual)
  Future<bool> submitLostItem({
    required String nama,
    required String noHp,
    String? deskripsi,
    required String jenisBarang,
    required String area,
    File? image,
  }) async {
    final report = LostItemReport(
      namaPelapor: nama,
      noHpPelapor: noHp,
      deskripsi: deskripsi,
      jenisBarang: jenisBarang,
      area: area,
      foto: image,
    );

    return await submitLostItemReport(report);
  }
}
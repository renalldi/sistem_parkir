import 'dart:convert'; // <- perlu untuk jsonDecode
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/lost_item_model.dart';

class LostItemService {
  static const String baseUrl = 'https://192.168.111.40:7211';

  static Future<bool> submitLostItemReport(LostItemReport report, String token) async {
    final url = Uri.parse('$baseUrl/api/Record');

    var request = http.MultipartRequest('POST', url);

    // Header Authorization JWT
    request.headers['Authorization'] = 'Bearer $token';

    // Tambah field data
    request.fields.addAll(report.toJson());

    // Upload foto jika ada
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

  // ✅ Method untuk dipanggil dari Provider/UI
  Future<bool> submitLostItem({
    required String namaPelapor,
    required String noHpPelapor,
    String? deskripsi, // opsional
    required String jenisBarang,
    required String area,
    File? image,
    required String token,
  }) async {
    final report = LostItemReport(
      namaPelapor: namaPelapor,
      noHpPelapor: noHpPelapor,
      deskripsi: deskripsi,
      jenisBarang: jenisBarang,
      area: area,
      foto: image,
    );

    return await submitLostItemReport(report, token);
  }

  // ✅ Method baru untuk ambil semua laporan kehilangan
  Future<List<LostItemReport>> getAllLostItem() async {
    // final url = Uri.parse('$baseUrl/api/Record');

    // try {
    //   final response = await http.get(url);

    final url = Uri.parse('$baseUrl/api/Record');
    print('📡 Fetching from: $url');

    try {

      final response = await http.get(url);
      print('📥 Response Body: ${response.body}');


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LostItemReport.fromJson(item)).toList();
      } else {
        print('❌ Gagal mengambil data kehilangan: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('🔥 Error saat ambil data kehilangan: $e');
      return [];
    }
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sistem_parkir/models/parking_report_model.dart'; 

class ReportService {
  static const String baseUrl = "https://192.168.111.40:7211/api/Report";

  /// 🔸 Kirim laporan kendaraan
  static Future<int?> submitReport({
    required String plat,
    required String nama,
    required String spot,
    required String deskripsi,
    Uint8List? gambarBytes,
    String? gambarName,
  }) async {
    try {
      final uri = Uri.parse(baseUrl);
      final request = http.MultipartRequest("POST", uri);

      request.fields["platMotor"] = plat;
      request.fields["namaMotor"] = nama;
      request.fields["spot"] = spot;
      request.fields["deskripsi"] = deskripsi;

      if (gambarBytes != null && gambarName != null) {
        final mimeType = lookupMimeType(gambarName) ?? 'image/jpeg';
        final contentType = MediaType.parse(mimeType);

        request.files.add(http.MultipartFile.fromBytes(
          "gambar",
          gambarBytes,
          filename: gambarName,
          contentType: contentType,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["id"]; // Asumsikan response {"id": ...}
      } else {
        print("Gagal kirim laporan: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception saat kirim laporan: $e");
      return null;
    }
  }

  /// 🔸 Ambil semua laporan kendaraan
  Future<List<ParkingReportModel>> getAllReport() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParkingReportModel.fromJson(json)).toList();
      } else {
        throw Exception("Gagal mengambil data laporan kendaraan");
      }
    } catch (e) {
      throw Exception("Error mengambil laporan kendaraan: $e");
    }
  }

  /// 🔸 Hapus laporan berdasarkan ID
  Future<void> deleteParkingReport(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));

      if (response.statusCode != 200) {
        throw Exception("Gagal menghapus laporan. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error saat menghapus laporan: $e");
    }
  }
}
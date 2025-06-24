import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/parking_report_model.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

  class ParkingReportService {
  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'https://192.168.111.40:7211');


  /// Ambil record berdasarkan ID
  Future<ParkingReportModel> getRecordById(String id) async {
    final url = Uri.parse('$baseUrl/api/Record/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ParkingReportModel.fromJson(data);
    } else {
      throw Exception('Failed to load record');
    }
  }

  /// Submit laporan baru
  Future<String?> submitReport({
    required String plat,
    required String nama,
    required String spot,
    required String deskripsi,
    required Uint8List? gambarBytes,
  }) async {
    final url = Uri.parse('$baseUrl/api/Record');

    var request = http.MultipartRequest('POST', url);
    request.fields['platMotor'] = plat;
    request.fields['namaMotor'] = nama;
    request.fields['spot'] = spot;
    request.fields['deskripsi'] = deskripsi;

    if (gambarBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'gambar',
        gambarBytes,
        filename: 'upload.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']?.toString();
    } else {
      print('Submit failed: ${response.body}');
      return null;
    }
  }
  Future<List<ParkingReportModel>> getAllReports() async {
  final response = await http.get(Uri.parse("$baseUrl/api/report")); // asumsi endpoint ini
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data.map((json) => ParkingReportModel.fromJson(json)).toList();
  } else {
    throw Exception("Gagal memuat data laporan");
  }
}

}
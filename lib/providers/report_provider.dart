import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sistem_parkir/services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  // Data form
  String platMotor = '';
  String namaMotor = '';
  String spot = '';
  String deskripsi = '';

  // Data gambar
  Uint8List? gambarBytes;
  String? gambarFileName;

  // Update field teks
  void updatePlat(String value) => platMotor = value;
  void updateNama(String value) => namaMotor = value;
  void updateSpot(String value) => spot = value;
  void updateDeskripsi(String value) => deskripsi = value;

  // Update gambar (trigger UI update juga)
  void updateGambar(Uint8List bytes, String fileName) {
    gambarBytes = bytes;
    gambarFileName = fileName;
    notifyListeners();
  }

  /// Kirim laporan ke backend menggunakan ReportService
  Future<int?> submitReport() async {
    try {
      final result = await ReportService.submitReport(
        plat: platMotor,
        nama: namaMotor,
        spot: spot,
        deskripsi: deskripsi,
        gambarBytes: gambarBytes,
        gambarName: gambarFileName,
      );
      return result;
    } catch (e) {
      debugPrint('Gagal kirim laporan: $e');
      return null;
    }
  }

  // Reset form setelah submit
  void reset() {
    platMotor = '';
    namaMotor = '';
    spot = '';
    deskripsi = '';
    gambarBytes = null;
    gambarFileName = null;
    notifyListeners();
  }
}

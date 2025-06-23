import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/park_service.dart';
import '../services/token_storage.dart';

class ParkingProvider extends ChangeNotifier {
  final ParkingService _service = ParkingService();
  List<dynamic> _areaStatus = [];

  List<dynamic> get areaStatus => _areaStatus;

  int? riwayatId; // ID riwayat parkir yang sedang aktif

  Future<void> loadStatus() async {
    _areaStatus = await _service.fetchParkingStatus();
    notifyListeners();
  }

  Future<int> parkirMasuk(int userId, int areaId) async {
    final id = await _service.parkirMasuk(userId, areaId);
    riwayatId = id;
    await loadStatus();
    return id;
  }

  Future<void> parkirKeluar(int? id) async {
    if (id == null) throw Exception("ID parkir tidak ditemukan");
    await _service.parkirKeluar(id);
    await loadStatus();
  }

  Future<int?> cekParkirAktif(int userId) async {
  final url = Uri.parse('${ParkingService.baseUrl}/api/parkir/status/$userId');
  final response = await http.get(url, headers: await TokenStorage.getAuthHeaders());

  if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['active'] == true) {
        riwayatId = json['riwayatId']; // simpan riwayat aktif!
        return json['areaId']; // buat tandai area warna biru
      }
      return null;
    } else {
      throw Exception('Gagal cek status parkir');
    }
  }

}


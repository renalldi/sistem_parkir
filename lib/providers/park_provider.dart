import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/park_service.dart';
import '../services/token_storage.dart';

class ParkingProvider extends ChangeNotifier {
  final ParkingService _service = ParkingService();
  List<dynamic> _areaStatus = [];

  List<dynamic> get areaStatus => _areaStatus;

  Map<int, int> areaOccupancy = {
    1: 0, // Mahasiswa 1
    2: 0, // Mahasiswa 2
    3: 0, // Mahasiswa 3
    4: 0, // Dosen & Staff
  };

  Map<int, int> areaCapacity = {
    1: 50, // kapasitas Mahasiswa 1
    2: 30,
    3: 25,
    4: 20, // kapasitas Dosen & Staff
  };

  int? riwayatId; // ID riwayat parkir yang sedang aktif

  Future<void> loadStatus() async {
    _areaStatus = await _service.fetchParkingStatus();

    // Reset occupancy ke nol
    areaOccupancy.updateAll((key, value) => 0);

    // Hitung ulang berdasarkan data yang didapat
    for (var item in _areaStatus) {
      final int areaId = item['id_Area'];
      final int kapasitas = item['kapasitas_Area'];
      final int terisi = item['terisi'];

      areaCapacity[areaId] = kapasitas;
      areaOccupancy[areaId] = terisi;
    }

    notifyListeners();
  }

  void updateOccupancy(int areaId, int delta) {
    areaOccupancy[areaId] = (areaOccupancy[areaId] ?? 0) + delta;
    if (areaOccupancy[areaId]! < 0) areaOccupancy[areaId] = 0;
    notifyListeners();
  }

  Future<int> parkirMasuk(int userId, int areaId) async {
    final id = await _service.parkirMasuk(userId, areaId);
    riwayatId = id;
    updateOccupancy(areaId, 1); // tambah jumlah parkir
    await loadStatus();
    return id;
  }

  Future<void> parkirKeluar(int? id, {int? areaId}) async {
    if (id == null) throw Exception("ID parkir tidak ditemukan");
    await _service.parkirKeluar(id);
    if (areaId != null) {
      updateOccupancy(areaId, -1); // kurangi jumlah parkir
    }
    await loadStatus();
  }

  Future<int?> cekParkirAktif(int userId) async {
    final url = Uri.parse('${ParkingService.baseUrl}/api/parkir/status/$userId');
    final response = await http.get(url, headers: await TokenStorage.getAuthHeaders());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['active'] == true) {
        riwayatId = json['riwayatId']; // simpan id riwayat aktif
        return json['areaId']; // tandai area yang sedang dipakai user
      }
      return null;
    } else {
      throw Exception('Gagal cek status parkir');
    }
  }
}

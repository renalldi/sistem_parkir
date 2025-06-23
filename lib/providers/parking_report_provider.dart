import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/parking_report_model.dart';
import '../services/parking_report_service.dart';

class ParkingReportProvider with ChangeNotifier {
  // ======== State Laporan (untuk form) ========
  String _platMotor = '';
  String _namaMotor = '';
  String _spot = '';
  String _deskripsi = '';
  Uint8List? _gambarBytes;
  String? _gambarName;

  // Getter untuk Form
  String get platMotor => _platMotor;
  String get namaMotor => _namaMotor;
  String get spot => _spot;
  String get deskripsi => _deskripsi;
  Uint8List? get gambarBytes => _gambarBytes;
  String? get gambarName => _gambarName;

  // Updater untuk Form
  void updatePlat(String value) {
    _platMotor = value;
    notifyListeners();
  }

  void updateNama(String value) {
    _namaMotor = value;
    notifyListeners();
  }

  void updateSpot(String value) {
    _spot = value;
    notifyListeners();
  }

  void updateDeskripsi(String value) {
    _deskripsi = value;
    notifyListeners();
  }

  void updateGambar(Uint8List bytes, String name) {
    _gambarBytes = bytes;
    _gambarName = name;
    notifyListeners();
  }

  void reset() {
    _platMotor = '';
    _namaMotor = '';
    _spot = '';
    _deskripsi = '';
    _gambarBytes = null;
    _gambarName = null;
    notifyListeners();
  }

  // ======== State Record Detail (untuk screen /record) ========
  ParkingReportModel? _record;
  bool _isLoading = false;

  ParkingReportModel? get record => _record;
  bool get isLoading => _isLoading;

  Future<void> fetchRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ParkingReportService().getRecordById(id);
      _record = result;
    } catch (e) {
      _record = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _record = null;
    notifyListeners();
  }

  // ======== Submit Report ke API ========
  Future<String?> submitReport() async {
    try {
      final id = await ParkingReportService().submitReport(
        plat: _platMotor,
        nama: _namaMotor,
        spot: _spot,
        deskripsi: _deskripsi,
        gambarBytes: _gambarBytes,
      );
      return id;
    } catch (e) {
      return null;
    }
  }

    // ======== State Riwayat Laporan ========
  List<ParkingReportModel> _recordList = [];
  bool _isHistoryLoading = false;

  List<ParkingReportModel> get recordList => _recordList;
  bool get isHistoryLoading => _isHistoryLoading;

  Future<void> fetchAllReport() async {
    _isHistoryLoading = true;
    notifyListeners();

    try {
      final result = await ParkingReportService().getAllReports();
      _recordList = result;
    } catch (e) {
      _recordList = [];
    }

    _isHistoryLoading = false;
    notifyListeners();
  }

}
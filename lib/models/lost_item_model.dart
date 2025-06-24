import 'dart:io';

class LostItemReport {
  final int? id;
  final String namaPelapor;
  final String noHpPelapor;
  final String? deskripsi;
  final String jenisBarang;
  final String area;
  final File? foto;
  final String? fotoPath;
  final DateTime? tanggalLapor;

  LostItemReport({
    this.id,
    required this.namaPelapor,
    required this.noHpPelapor,
    required this.jenisBarang,
    required this.area,
    this.deskripsi,
    this.foto,
    this.fotoPath,
    this.tanggalLapor,
  });

  // 🔼 Untuk dikirim ke backend (POST)
  Map<String, String> toJson() {
    final data = {
      'namaPelapor': namaPelapor,
      'noHpPelapor': noHpPelapor,
      'jenisBarang': jenisBarang,
      'area': area,
    };

    if (deskripsi != null && deskripsi!.isNotEmpty) {
      data['deskripsi'] = deskripsi!;
    }

    return data;
  }

  // 🔽 Untuk menerima dari backend (GET)
  factory LostItemReport.fromJson(Map<String, dynamic> json) {
    return LostItemReport(
      id: json['id'],
      namaPelapor: json['namaPelapor'] ?? '',
      noHpPelapor: json['noHpPelapor'] ?? '',
      jenisBarang: json['jenisBarang'] ?? '',
      area: json['area'] ?? '',
      deskripsi: json['deskripsi'] ?? 'Tidak ada deskripsi',
      fotoPath: json['fotoUrl'],
      tanggalLapor: DateTime.tryParse(json['tanggalLapor'] ?? ''),
    );
  }
}
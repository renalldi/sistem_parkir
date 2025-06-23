import 'dart:io';

class LostItemReport {
  final String namaPelapor;
  final String noHpPelapor;
  final String? deskripsi;     // opsional
  final String jenisBarang;    // "Pribadi" / "Milik Orang Lain"
  final String area;           // "Mahasiswa 1", dst
  final File? foto;
  final String? fotoPath;
  final DateTime? tanggalLapor;

  LostItemReport({
    required this.namaPelapor,
    required this.noHpPelapor,
    required this.jenisBarang,
    required this.area,
    this.deskripsi,
    this.foto,
    this.fotoPath,
    this.tanggalLapor,
  });

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

  factory LostItemReport.fromJson(Map<String, dynamic> json) {
    return LostItemReport(
      namaPelapor: json['namaPelapor'],
      noHpPelapor: json['noHpPelapor'],
      jenisBarang: json['jenisBarang'],
      area: json['area'],
      deskripsi: json['deskripsi'],
      fotoPath: json['fotoPath'],
      tanggalLapor: DateTime.tryParse(json['tanggalLapor'] ?? ''),
    );
  }
}

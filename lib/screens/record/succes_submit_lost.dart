import 'package:flutter/material.dart';
import 'package:sistem_parkir/themes/theme.dart';
import '../home/home_page.dart';

class LaporanBerhasilPage extends StatelessWidget {
  final String area;
  final String deskripsi;
  final String waktu;

  const LaporanBerhasilPage({
    Key? key,
    required this.area,
    required this.deskripsi,
    required this.waktu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      appBar: AppBar(
        backgroundColor: FigmaColors.primer,
        elevation: 0,
        title: Text('Laporan Barang Hilang', style: FigmaTextStyles.body),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔷 Kotak info laporan
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Berhasil Melapor', style: FigmaTextStyles.body),
                  SizedBox(height: 8),
                  Text(waktu, style: FigmaTextStyles.hint),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Area'),
                      Text(area, style: FigmaTextStyles.body),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Deskripsi'),
                      Text(deskripsi, style: FigmaTextStyles.body),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 🔷 Kotak bawah panjang penuh
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Terimakasih sudah melapor ✨',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '⚠️\nTOLONG BARANGNYA DI KEEP TERLEBIH DAHULU!\n⚠️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fakultas Ilmu Komputer',
                    textAlign: TextAlign.center,
                    style: FigmaTextStyles.hint,
                  ),
                ],
              ),
            ),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
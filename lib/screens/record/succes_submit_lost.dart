import 'package:flutter/material.dart';
import 'package:sistem_parkir/themes/theme.dart';

class LaporanBerhasilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      appBar: AppBar(
        backgroundColor: FigmaColors.primer,
        elevation: 0,
        title: Text('Laporan Barang Hilang', style: FigmaTextStyles.body),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  Text('waktu • pelaporan', style: FigmaTextStyles.hint),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Area'),
                      Text('Student Parking', style: FigmaTextStyles.body),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Deskripsi'),
                      Text('Barang Hilang', style: FigmaTextStyles.body),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32), // tambahin tinggi
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Terimakasih sudah melapor ✨',
                      style: TextStyle(fontSize: 16)), // hindari FigmaTextStyles untuk emoji
                  SizedBox(height: 12),
                  Text(
                    '⚠️\nTOLONG BARANGNYA DI KEEP TERLEBIH DAHULU!\n⚠️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 12),
                  Text('Fakultas Ilmu Komputer', style: FigmaTextStyles.hint),
                ],
              ),
            ),
            SizedBox(height: 120), // beri spasi bawah biar gak terlalu rapat ke edge
          ],
        ),
      ),
    );
  }
}
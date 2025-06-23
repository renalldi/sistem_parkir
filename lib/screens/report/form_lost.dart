import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sistem_parkir/themes/theme.dart';
import '../record/succes_submit_lost.dart';

class FormLostPage extends StatefulWidget {
  const FormLostPage({super.key});

  @override
  State<FormLostPage> createState() => _FormLostPageState();
}

class _FormLostPageState extends State<FormLostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final List<String> _areaOptions = ['Mahasiswa 1', 'Mahasiswa 2', 'Mahasiswa 3', 'Dosen & Staff'];

  String? _selectedArea;
  String? _jenisBarang;
  File? _foto;
  DateTime waktuLapor = DateTime.now();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_jenisBarang == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jenis barang harus dipilih')),
        );
        return;
      }

      if (_foto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto barang harus dipilih')),
        );
        return;
      }

      if (_selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Area lokasi harus dipilih')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah data yang Anda isi sudah benar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _navigateToSuccessPage(); // Pindah halaman
              },
              child: const Text('Ya, Submit'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToSuccessPage() {
    print('--- DATA FORM KEHILANGAN ---');
    print('Nama: ${_namaController.text}');
    print('No HP: ${_noHpController.text}');
    print('Jenis Barang: $_jenisBarang');
    print('Deskripsi: ${_deskripsiController.text.isNotEmpty ? _deskripsiController.text : 'Tidak diisi'}');
    print('Foto: ${_foto?.path}');
    print('Area: $_selectedArea');
    print('Waktu Lapor: $waktuLapor');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LaporanBerhasilPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      appBar: AppBar(
        title: const Text('Laporan Kehilangan'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Text('Nama Pelapor', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              TextFormField(
                controller: _namaController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) return 'Hanya huruf dan spasi';
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FigmaColors.field,
                  hintText: 'contoh: Mingyu',
                  hintStyle: FigmaTextStyles.hint,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              Text('No. Hp Pelapor', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) return 'Nomor tidak valid';
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FigmaColors.field,
                  hintText: 'contoh: 081234567890',
                  hintStyle: FigmaTextStyles.hint,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              Text('Jenis Barang', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: FigmaColors.field,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _jenisBarang,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: Text('Pilih jenis barang', style: FigmaTextStyles.hint),
                  items: ['pribadi', 'milik orang lain']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _jenisBarang = value),
                  validator: (value) => value == null ? 'Wajib dipilih' : null,
                ),
              ),
              const SizedBox(height: 16),
              Text('Area Lokasi', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: FigmaColors.field,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedArea,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: Text('Pilih area lokasi', style: FigmaTextStyles.hint),
                  items: _areaOptions
                      .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedArea = value),
                  validator: (value) => value == null ? 'Wajib dipilih' : null,
                ),
              ),
              const SizedBox(height: 16),
              Text('Foto Barang', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: FigmaColors.field,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _foto != null ? '📷 Foto terpilih' : 'Pilih gambar (kamera/galeri)',
                    style: FigmaTextStyles.hint,
                  ),
                ),
              ),
              if (_foto != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(_foto!, height: 120),
                ),
              ],
              const SizedBox(height: 16),
              Text('Deskripsi', style: FigmaTextStyles.body),
              const SizedBox(height: 4),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FigmaColors.field,
                  hintText: 'opsional',
                  hintStyle: FigmaTextStyles.hint,
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FigmaColors.primer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitForm,
                child: Text('Submit', style: FigmaTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
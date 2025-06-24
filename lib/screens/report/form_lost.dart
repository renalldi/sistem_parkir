import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistem_parkir/themes/theme.dart';
import 'dart:io' as io; // Untuk Android/iOS
// import 'dart:html' as html; // Untuk Web
import '../record/succes_submit_lost.dart';

class FormLostPage extends StatefulWidget {
  const FormLostPage({super.key});

  @override
  State<FormLostPage> createState() => _FormLostPageState();
}

class _FormLostPageState extends State<FormLostPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final List<String> _areaOptions = [
    'Mahasiswa 1',
    'Mahasiswa 2',
    'Mahasiswa 3',
    'Dosen & Staff',
  ];

  String? _selectedArea;
  String? _jenisBarang;
  io.File? _fotoMobile;
  Uint8List? _fotoWeb;
  String? _webFileName;
  DateTime waktuLapor = DateTime.now();

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // final uploadInput = html.FileUploadInputElement();
      // uploadInput.accept = 'image/*';
      // uploadInput.click();

      // uploadInput.onChange.listen((event) {
      //   final file = uploadInput.files?.first;
      //   if (file != null) {
      //     final reader = html.FileReader();
      //     reader.readAsArrayBuffer(file);
      //     reader.onLoadEnd.listen((event) {
      //       setState(() {
      //         _fotoWeb = reader.result as Uint8List;
      //         _webFileName = file.name;
      //       });
      //     });
      //   }
      // });
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _fotoMobile = io.File(pickedFile.path);
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_jenisBarang == null) {
        _showSnackbar('Jenis barang harus dipilih');
        return;
      }
      if (_selectedArea == null) {
        _showSnackbar('Area lokasi harus dipilih');
        return;
      }
      if (!kIsWeb && _fotoMobile == null || kIsWeb && _fotoWeb == null) {
        _showSnackbar('Foto barang harus dipilih');
        return;
      }
      _showConfirmationDialog();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah data yang Anda isi sudah benar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSuccessPage();
            },
            child: const Text('Ya, Submit'),
          ),
        ],
      ),
    );
  }

  void _navigateToSuccessPage() async {
    print('--- DATA FORM KEHILANGAN ---');
    print('Nama: ${_namaController.text}');
    print('No HP: ${_noHpController.text}');
    print('Jenis Barang: $_jenisBarang');
    print('Deskripsi: ${_deskripsiController.text.isNotEmpty ? _deskripsiController.text : 'Tidak diisi'}');
    print('Area: $_selectedArea');
    print('Waktu Lapor: $waktuLapor');
    print('Foto: ${kIsWeb ? _webFileName : _fotoMobile?.path}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaporanBerhasilPage(
          area: _selectedArea!,
          deskripsi: _deskripsiController.text.isNotEmpty ? _deskripsiController.text : 'Tidak diisi',
          waktu: waktuLapor.toString(),
        ),
      ),
    );

    // ✅ Setelah berhasil ➜ kembali ke Home
    Navigator.pop(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildLabel('Nama Pelapor'),
              _buildTextField(
                controller: _namaController,
                hint: 'contoh: Mingyu',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) return 'Hanya huruf dan spasi';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('No. Hp Pelapor'),
              _buildTextField(
                controller: _noHpController,
                hint: 'contoh: 081234567890',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) return 'Nomor tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('Jenis Barang'),
              _buildDropdown(
                value: _jenisBarang,
                hint: 'Pilih jenis barang',
                items: ['pribadi', 'milik orang lain'],
                onChanged: (value) => setState(() => _jenisBarang = value),
              ),
              const SizedBox(height: 16),
              _buildLabel('Area Lokasi'),
              _buildDropdown(
                value: _selectedArea,
                hint: 'Pilih area lokasi',
                items: _areaOptions,
                onChanged: (value) => setState(() => _selectedArea = value),
              ),
              const SizedBox(height: 16),
              _buildLabel('Foto Barang'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: FigmaColors.field,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (kIsWeb && _fotoWeb != null) || (!kIsWeb && _fotoMobile != null)
                        ? '📷 Foto terpilih'
                        : 'Pilih gambar (kamera/galeri)',
                    style: FigmaTextStyles.hint,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!kIsWeb && _fotoMobile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(_fotoMobile!, height: 120),
                )
              else if (kIsWeb && _fotoWeb != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(_fotoWeb!, height: 120),
                ),
              const SizedBox(height: 16),
              _buildLabel('Deskripsi'),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FigmaColors.field,
                  hintText: 'opsional',
                  hintStyle: FigmaTextStyles.hint,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FigmaColors.primer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildLabel(String text) => Text(text, style: FigmaTextStyles.body);

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: FigmaColors.field,
        hintText: hint,
        hintStyle: FigmaTextStyles.hint,
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FigmaColors.field,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: FigmaTextStyles.hint),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Wajib dipilih' : null,
      ),
    );
  }
}
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_parkir/providers/report_provider.dart';


import 'package:image_picker/image_picker.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;

class FormReportPage extends StatefulWidget {
  const FormReportPage({super.key});

  @override
  State<FormReportPage> createState() => _FormReportPageState();
}

class _FormReportPageState extends State<FormReportPage> {
  @override
  void initState() {
    super.initState();
    // Reset provider ketika halaman dimulai
    Future.microtask(() {
      context.read<ReportProvider>().reset();
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final provider = context.read<ReportProvider>();

    if (kIsWeb) {
      // === WEB ===
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.setAttribute('capture', 'environment');
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final file = uploadInput.files?.first;
        if (file != null) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((event) {
            final bytes = reader.result as Uint8List;
            provider.updateGambar(bytes, file.name);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gambar berhasil diambil')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengambil gambar')),
          );
        }
      });
    } else {
      // === ANDROID / IOS ===
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        provider.updateGambar(bytes, pickedFile.name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diambil')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar')),
        );
      }
    }
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFCB),
      appBar: AppBar(
        title: const Text("Form Report"),
        backgroundColor: const Color(0xFFDAB43D),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child : Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField("Plat Motor", initialValue: provider.platMotor, onChanged: provider.updatePlat),
              const SizedBox(height: 16),
              buildTextField("Nama Motor", initialValue: provider.namaMotor, onChanged: provider.updateNama),
              const SizedBox(height: 16),
              buildTextField("Spot", initialValue: provider.spot, onChanged: provider.updateSpot),
              const SizedBox(height: 16),
              buildTextField(
                "Deskripsi Kendaraan",
                initialValue: provider.deskripsi,
                maxLines: 3,
                onChanged: provider.updateDeskripsi,
              ),
              const SizedBox(height: 24),

              const Text("Upload Gambar:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              provider.gambarBytes != null
                  ? Image.memory(provider.gambarBytes!, height: 150)
                  : const Text("Belum ada gambar dipilih."),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil Gambar dari Kamera"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDAB43D)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    // validasi input
                    if (!_formkey.currentState!.validate()) return;

                    // validasi gambar
                    if (provider.gambarBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gambar belum dipilih")),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    final newId = await provider.submitReport();

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      if (newId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Laporan berhasil dikirim (ID: $newId)"),
                        ));
                        provider.reset();
                        Navigator.pushReplacementNamed(
                          context,
                          '/record',
                          arguments: newId,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Gagal mengirim laporan"),
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDAB43D)),
                  child: const Text("Kirim Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label, {
    int maxLines = 1,
    required Function(String) onChanged,
    required String initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
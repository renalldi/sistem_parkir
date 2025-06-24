import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parking_report_provider.dart';
import 'package:sistem_parkir/themes/theme.dart';

class RecordScreen extends StatefulWidget {
  final String id;

  const RecordScreen({super.key, required this.id});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      Provider.of<ParkingReportProvider>(context, listen: false).fetchRecord(widget.id);
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingReportProvider>(context);
    final record = provider.record;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: FigmaColors.primer,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Laporan',
          style: FigmaTextStyles.heading.copyWith(fontSize: 20),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : record == null
              ? const Center(child: Text("Gagal memuat data laporan"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Card untuk info utama kendaraan
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: FigmaColors.primer,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Issue Recorded!",
                                  style: FigmaTextStyles.heading,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Spot Description",
                                      style: FigmaTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      record.description,
                                      style: FigmaTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(record.vehicle, style: FigmaTextStyles.body),
                                    Text(record.plate, style: FigmaTextStyles.body),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card untuk gambar dan fakultas + tombol
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: FigmaColors.background,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Record ID : ${record.id}",
                                  style: FigmaTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                record.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          record.imageUrl,
                                          height: 200,
                                        ),
                                      )
                                    : Text(
                                        "Tidak ada gambar",
                                        style: FigmaTextStyles.hint,
                                      ),
                                const SizedBox(height: 12),
                                Text(
                                  "The Recorded Vehicle",
                                  style: FigmaTextStyles.body,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.faculty,
                                  style: FigmaTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ✅ Tombol kembali ke beranda
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: FigmaColors.primer,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/home', (route) => false);
                                    },
                                    child: Text(
                                      "Kembali ke Beranda",
                                      style: FigmaTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
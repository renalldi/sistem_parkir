import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_parkir/providers/parking_report_provider.dart';
import 'package:sistem_parkir/themes/theme.dart';
import '/screens/record/succes_submit_report.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      Provider.of<ParkingReportProvider>(context, listen: false).fetchAllReport();
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParkingReportProvider>();
    final records = provider.recordList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Laporan"),
        backgroundColor: FigmaColors.primer,
      ),
      body: provider.isHistoryLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("Belum ada laporan yang dikirim."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          record.plate,
                          style: FigmaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(record.description),
                            const SizedBox(height: 4),
                            Text("Spot: ${record.faculty}", style: FigmaTextStyles.hint),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordScreen(id: record.id.toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

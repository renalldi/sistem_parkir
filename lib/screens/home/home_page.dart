import 'package:flutter/material.dart';
import 'package:sistem_parkir/screens/park_view_screen.dart';
import 'package:sistem_parkir/screens/report/form_report.dart';
import 'package:sistem_parkir/screens/report/form_lost.dart';
import 'package:sistem_parkir/screens/home/account_page.dart';
import 'package:sistem_parkir/themes/theme.dart';
import 'package:sistem_parkir/services/lost_item_service.dart';
// import 'package:sistem_parkir/services/parking_report_service.dart';
import 'package:sistem_parkir/models/lost_item_model.dart';
import 'package:sistem_parkir/models/parking_report_model.dart';
import 'package:sistem_parkir/services/report_service.dart';
import 'package:sistem_parkir/services/token_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeMenu(),
    const ParkViewScreen(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      appBar: AppBar(
        title: const Text("FasPark"),
        backgroundColor: FigmaColors.primer,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: FigmaColors.parkir,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Park View'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeMenu extends StatefulWidget {
  const _HomeMenu();

  @override
  State<_HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<_HomeMenu> {
  late Future<List<LostItemReport>> _lostItemsFuture;
  late Future<List<ParkingReportModel>> _vehicleReportsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    TokenStorage.getToken().then((token) {
      print("🔥 Token aktif: $token");
    });

    setState(() {
      _lostItemsFuture = LostItemService().getAllLostItem().then((items) => items.reversed.toList());
      _vehicleReportsFuture = ReportService().getAllReport().then((items) => items.reversed.toList());
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLostItemsTable(),
            const SizedBox(height: 24),
            _buildVehicleReportsTable(),
            const SizedBox(height: 24),
            _buildFormMenu(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FigmaColors.parkir,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("HI, PETUGAS!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          SizedBox(height: 4),
          Text("Selamat menjalankan tugas!", style: TextStyle(color: Colors.white)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text("Fakultas Ilmu Komputer", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLostItemsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Riwayat Kehilangan Barang", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<LostItemReport>>(
            future: _lostItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Belum ada laporan kehilangan.");
              }

              final items = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("No")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Jenis")),
                    DataColumn(label: Text("Area")),
                    DataColumn(label: Text("Tanggal")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: List.generate(items.length, (index) {
                    final item = items[index];
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(item.namaPelapor)),
                      DataCell(Text(item.jenisBarang)),
                      DataCell(Text(item.area)),
                      DataCell(Text(_formatDate(item.tanggalLapor))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => items.removeAt(index));
                          },
                        ),
                      ),
                    ]);
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleReportsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Riwayat Pelaporan Kendaraan", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<ParkingReportModel>>(
            future: _vehicleReportsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Belum ada laporan kendaraan.");
              }

              final reports = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("No")),
                    DataColumn(label: Text("Kendaraan")),
                    DataColumn(label: Text("Plat")),
                    DataColumn(label: Text("Area")),
                    DataColumn(label: Text("Aksi")),
                  ],
                  rows: List.generate(reports.length, (index) {
                    final item = reports[index];
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(item.vehicle)),
                      DataCell(Text(item.plate)),
                      DataCell(Text(item.faculty)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await ReportService().deleteParkingReport(item.id);
                              setState(() => reports.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Berhasil menghapus laporan")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal menghapus: $e")),
                              );
                            }
                          },
                        ),
                      ),
                    ]);
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Form Lainnya", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MenuCard(
                icon: Icons.search,
                label: "Form Kehilangan Barang",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormLostPage()),
                  ).then((_) => _loadData());
                },
              ),
              _MenuCard(
                icon: Icons.report,
                label: "Form Pelaporan Kendaraan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FormReportPage()),
                  ).then((_) => _loadData());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FigmaColors.parkir,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
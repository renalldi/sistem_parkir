// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/park_provider.dart';
import '../providers/auth_provider.dart';
import 'package:sistem_parkir/themes/theme.dart';

const bool isDevMode = true;

class ParkViewScreen extends StatefulWidget {
  const ParkViewScreen({super.key});

  @override
  State<ParkViewScreen> createState() => _ParkViewScreenState();
}

class _ParkViewScreenState extends State<ParkViewScreen> {
  String? userParkedAt;
  int? selectedAreaId;

  String _getNameFromAreaId(int id) {
    switch (id) {
      case 1:
        return "Mahasiswa 1";
      case 2:
        return "Mahasiswa 2";
      case 3:
        return "Mahasiswa 3";
      case 4:
        return "Dosen & Staff";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatusParkir();
      Provider.of<ParkingProvider>(context, listen: false).loadStatus();
    });
  }

  Future<void> _loadStatusParkir() async {
    final provider = Provider.of<ParkingProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    if (userId == null) return;

    try {
      final areaId = await provider.cekParkirAktif(userId);
      if (areaId != null) {
        setState(() {
          selectedAreaId = areaId;
          userParkedAt = _getNameFromAreaId(areaId);
        });
      }
    } catch (e) {
      print("❌ Gagal cek status parkir: $e");
    }
  }

  String getStatus(double percent) {
    if (percent > 90) return 'Penuh';
    if (percent > 50) return 'Hampir Penuh';
    return 'Parkir Tersedia';
  }

  Color getColorDashboard(double percent) {
    if (percent > 90) return Colors.red;
    if (percent > 50) return Colors.orange;
    return Colors.green;
  }

  Color getColor(String name, double percent) {
    if (userParkedAt == name) return Colors.blue;
    if (percent > 90) return Colors.red;
    if (percent > 50) return Colors.orange;
    return Colors.green;
  }

  Future<bool> isInsideFasilkomArea() async {
    if (isDevMode) return true;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      const fasilkomLat = -6.3628;
      const fasilkomLon = 106.8246;
      const double maxDistanceInMeters = 100;

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        fasilkomLat,
        fasilkomLon,
      );

      return distance <= maxDistanceInMeters;
    } catch (e) {
      print("❌ Error lokasi: $e");
      return false;
    }
  }

  void handleTap(String name) async {
    final provider = Provider.of<ParkingProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    final areaMapping = {
      "Mahasiswa 1": 1,
      "Mahasiswa 2": 2,
      "Mahasiswa 3": 3,
      "Dosen & Staff": 4,
    };
    final areaId = areaMapping[name];

    if (userId == null || areaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login atau area salah.")),
      );
      return;
    }

    if (userParkedAt == name) {
      final keluar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Mau keluar dari parkiran ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Iya")),
          ],
        ),
      );

      if (keluar == true) {
        try {
          await provider.parkirKeluar(provider.riwayatId, areaId: areaId);
          setState(() => userParkedAt = null);
        } catch (e) {
          print("❌ Gagal keluar: $e");
        }
      }
    } else {
      final masuk = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Konfirmasi"),
          content: Text("Parkir di $name?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Iya")),
          ],
        ),
      );

      if (masuk == true) {
        final allowed = await isInsideFasilkomArea();
        if (!allowed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kamu tidak berada di area Fasilkom!")),
          );
          return;
        }

        try {
          final riwayatId = await provider.parkirMasuk(userId, areaId);
          setState(() => userParkedAt = name);
        } catch (e) {
          print("❌ Gagal parkir masuk: $e");
        }
      }
    }
  }

  Widget parkingBlock({required String name, required double percent, required Widget child}) {
    return Material(
      color: getColor(name, percent),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => handleTap(name),
        borderRadius: BorderRadius.circular(8),
        child: Center(child: child),
      ),
    );
  }

  Widget buildParkingCard(String title, int areaId) {
    final provider = Provider.of<ParkingProvider>(context);
    final occupancy = provider.areaOccupancy[areaId] ?? 0;
    final capacity = provider.areaCapacity[areaId] ?? 1;
    final percent = (occupancy / capacity) * 100;

    return SizedBox(
      width: 80,
      height: 90,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getColorDashboard(percent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("${percent.toInt()}%", style: const TextStyle(color: Colors.white)),
            Text(getStatus(percent),
                style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final Map<int, int> occupancy = provider.areaOccupancy;
    final Map<int, int> capacity = provider.areaCapacity;

    double percent(int id) {
      final cap = capacity[id] ?? 1;
      final occ = occupancy[id] ?? 0;
      return (occ / cap) * 100;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1D6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text("Denah Parkir Fasilkom", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text("3 Tempat Parkir Mahasiswa & 1 Tempat Parkir Dosen", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildParkingCard("Mahasiswa 1", 1),
                  buildParkingCard("Mahasiswa 2", 2),
                  buildParkingCard("Mahasiswa 3", 3),
                  buildParkingCard("Dosen", 4),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 60,
                        right: 60,
                        child: SizedBox(
                          height: 30,
                          child: parkingBlock(
                            name: "Mahasiswa 2",
                            percent: percent(2),
                            child: const Text("Mahasiswa 2", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 80,
                        bottom: 20,
                        width: 80,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: parkingBlock(
                            name: "Mahasiswa 1",
                            percent: percent(1),
                            child: const Text("Mahasiswa 1", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 75,
                        top: 110,
                        width: 80,
                        height: 130,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: parkingBlock(
                            name: "Mahasiswa 3",
                            percent: percent(3),
                            child: const Text("Mahasiswa 3", style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 100,
                        width: 50,
                        height: 300,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: parkingBlock(
                            name: "Dosen & Staff",
                            percent: percent(4),
                            child: const Text("Dosen & Staff", style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 80,
                        bottom: 10,
                        child: Text("SECURITY POST", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                      const Positioned(
                        top: 60,
                        left: 145,
                        child: CircleAvatar(radius: 15, backgroundColor: Colors.grey),
                      ),
                      const Positioned(
                        right: 5,
                        top: 40,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Center(
                            child: Text("ENTRANCE", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 100,
                        bottom: 135,
                        child: Text("GENSET", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (userParkedAt != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Anda parkir di $userParkedAt",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

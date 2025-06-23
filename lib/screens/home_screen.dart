import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  final Map<String, LatLng> lokasiTujuan = {
    "Fakultas Ilmu Komputer": LatLng(-8.165942440434762, 113.71687656035348),
    "Universitas Jember (UNEJ)": LatLng(-8.16501953086277, 113.71639153808526),
  };

  String selectedLokasi = "Fakultas Ilmu Komputer";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, User!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                "Need to find a spot at Fasilkom?",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[700]),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLokasi,
                      items: lokasiTujuan.keys.map((String namaLokasi) {
                        return DropdownMenuItem<String>(
                          value: namaLokasi,
                          child: Text(
                            namaLokasi,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedLokasi = value;
                          });
                          _mapController.move(
                              lokasiTujuan[value]!, _mapController.camera.zoom);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: lokasiTujuan[selectedLokasi]!,
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.mahasiswa_dosen.app',
              ),
              MarkerLayer(
                markers: lokasiTujuan.entries.map((entry) {
                  return Marker(
                    point: entry.value,
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_on,
                      color: entry.key == selectedLokasi
                          ? Colors.red
                          : Colors.grey[400],
                      size: 40,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


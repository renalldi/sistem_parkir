import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatefulWidget {
  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndNavigate();
  }

  Future<void> _checkPermissionAndNavigate() async {
    var status = await Permission.location.status;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permissionLevel = await Geolocator.checkPermission();

    if (status.isGranted && serviceEnabled && permissionLevel != LocationPermission.deniedForever) {
      Navigator.pushReplacementNamed(context, '/role');
    } else {
      // selesai cek, tampilkan tombol enable
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _requestLocation(BuildContext context) async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Layanan lokasi belum aktif. Aktifkan dulu di pengaturan.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin ditolak permanen. Aktifkan secara manual di pengaturan.')),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, '/role');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin Lokasi diperlukan untuk lanjut ke halaman selanjutnya')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1D16A),
      body: Center(
        child: _isChecking
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 100, color: Colors.red),
                  Text(
                    "Where do you wanna park",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _requestLocation(context),
                    child: Text('Enable Location'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Izin Lokasi Diperlukan Untuk Menggunakan Aplikasi Ini")),
                      );
                    },
                    child: Text('Not Now'),
                  ),
                ],
              ),
      ),
    );
  }
}

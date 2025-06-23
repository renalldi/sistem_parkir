import 'package:flutter/material.dart';
// import 'package:sistem_parkir/screens/main_screen.dart';
// import 'package:sistem_parkir/screens/auth/login_petugas.dart';

class RoleSelectionScreen extends StatelessWidget {
  void _selectRole(BuildContext context, String role) {
    // Mengarahkan ke halaman sesuai role
    if (role == 'User') {
      Navigator.pushReplacementNamed(context, '/login-user'); // menuju halaman login
    } else if (role == 'Petugas') {
      Navigator.pushReplacementNamed(context, '/login-petugas'); // menuju LoginPetugas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1D16A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_sharp, size: 100,),
            Text("Who are u?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'User'),
              child: Text("Dosen, Mahasiswa"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'Petugas'),
              child: Text("Petugas Parkir"),
            ),
          ],
        ),
      ),
    );
  }
}
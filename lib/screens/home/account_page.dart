import 'package:flutter/material.dart';
import 'package:sistem_parkir/themes/theme.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas dengan background primer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text("Profil", style: FigmaTextStyles.heading),
                        const SizedBox(height: 16),
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Form Nama dan Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nama", style: FigmaTextStyles.body),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: FigmaColors.field,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Petugas Parkir FASILKOM",
                        hintStyle: FigmaTextStyles.hint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ganti '/login' dengan route yang sesuai di aplikasi kamu
                          Navigator.of(context).pushNamedAndRemoveUntil('/role', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FigmaColors.primer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Logout", style: FigmaTextStyles.button),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "©Fakultas Ilmu Komputer",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: use_build_context_synchronously
// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../providers/auth_provider.dart';
// import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // XFile? _pickedImage;
  // final ImagePicker _picker = ImagePicker();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _usernameController.text = auth.username ?? "";
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _pickedImage = pickedFile;
  //     });
  //   }
  // }
  void _updateProfile() async {
    setState(() => _isLoading = true);

    final response = await UserService.updateProfile(
      Provider.of<AuthProvider>(context, listen: false).userId!.toString(),
      _usernameController.text,
      _passwordController.text,
      // _pickedImage,
    );

    if (response['success']) {
      // Update AuthProvider
      Provider.of<AuthProvider>(context, listen: false).updateUsername(_usernameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context); // Kembali ke ProfileScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "New Password (opsional)"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            // ElevatedButton(
            //   onPressed: _pickImage,
            //   child: const Text("Pilih Foto Profil")
            // ),
            // const SizedBox(height: 16),
            
            // // tampilkan preview foto (jika ada)
            // if (_pickedImage != null) 
            //   CircleAvatar(
            //     radius: 40,
            //     backgroundImage: FileImage(File(_pickedImage!.path)),
            //   ),
            _isLoading
                ? const  Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text("Simpan Perubahan"),
                  ),
          ],
        ),
      ),
    );
  }
}

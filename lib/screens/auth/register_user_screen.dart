import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'mahasiswa'; // Default role
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    final response = await UserService.register(
      _usernameController.text,
      _passwordController.text,
      _role,
    );

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil!")),
      );
      Navigator.pushReplacementNamed(context, '/login-user');
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
      appBar: AppBar(
        title: const Text("Register"),
        automaticallyImplyLeading: false,
        ),
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
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Role: "),
                Radio<String>(
                  value: 'mahasiswa',
                  groupValue: _role,
                  onChanged: (value) {
                    setState(() => _role = value!);
                  },
                ),
                const Text("Mahasiswa"),
                Radio<String>(
                  value: 'dosen',
                  groupValue: _role,
                  onChanged: (value) {
                    setState(() => _role = value!);
                  },
                ),
                const Text("Dosen"),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register"),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/login-user");
              },
              child: const Text("Sudah punya akun? Login disini"),
            ),
          ],
        ),
      ),
    );
  }
}
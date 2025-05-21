import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../widgets/absensi_main_button.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';
import '../widgets/main_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final user = body['user'];
        final token = body['token'];
        final role = user['role'];
        final userId = user['id'];

        if (token != null) {
          await _storage.write(key: 'token', value: token);
        }
        await _storage.write(key: 'role', value: role);
        await _storage.write(key: 'user_id', value: userId.toString());


        // Arahkan ke halaman utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout(role: role)),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password salah')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login gagal';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } on http.ClientException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server')),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu koneksi habis, coba lagi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Utils.mainThemeColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Utils.mainThemeColor, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.08),
              Center(
                child: Image.asset(
                  'assets/smanic.png',
                  width: size.width * 0.4,
                  height: size.width * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Absensi Siswa\nSMAN 1 CIAWI',
                style: TextStyle(
                  color: Utils.mainThemeColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                hintText: 'Email',
                icon: Icons.email,
                controller: emailController,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                hintText: 'Password',
                icon: Icons.lock,
                controller: passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AbsensiMainButton(label: 'Login', onTap: _login),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

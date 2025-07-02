import 'dart:convert';
import 'dart:async';
import 'package:absensi/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    print('Sending login request - Email: "$email", Password length: ${password.length}');

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan password wajib diisi')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email: email, password: password);
      final token = result['token'] as String;
      final user = result['user'] as Map<String, dynamic>;

      // Simpan ke FlutterSecureStorage
      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'role', value: user['role'] as String);
      await _storage.write(key: 'id_users', value: user['id'].toString());
      await _storage.write(key: 'nama', value: user['nama'] as String);
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'password', value: password);

      final prefs = await SharedPreferences.getInstance();
      final idSiswa = user['id_siswa'] as int?;
      if (idSiswa != null && idSiswa != 0) {
        await prefs.setInt('id_siswa', idSiswa);
        print('ID Siswa tersimpan: $idSiswa');
      } else {
        await prefs.remove('id_siswa');
        print('ID Siswa tidak ada atau tidak valid');
      }

      final idKelas = user['id_kelas'] as int?;
      if (idKelas != null && idKelas != 0) {
        await prefs.setInt('id_kelas', idKelas);
        print('ID Kelas tersimpan: $idKelas');
      } else {
        await prefs.remove('id_kelas');
        print('ID Kelas tidak ada atau tidak valid');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainLayout(role: user['role'] as String),
          ),
        );
      }
    } on http.ClientException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server')),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waktu koneksi habis, coba lagi')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('Login gagal')
            ? e.toString().replaceFirst('Exception: Login gagal: ', '')
            : 'Kesalahan: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
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
                  : _buildLoginButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    print('Response status: ${resp.statusCode}, Body: ${resp.body}');

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      // Simpan data ke SharedPreferences
      await prefs.setString('token', body['token']);
      await prefs.setInt('id_users', body['user']['id']);
      await prefs.setString('role', body['user']['role']);
      await prefs.setString('nama', body['user']['nama']);

      // Simpan id_siswa jika ada
      final idSiswa = body['user']['id_siswa'] as int?;
      if (idSiswa != null && idSiswa != 0) {
        await prefs.setInt('id_siswa', idSiswa);
        print('ID Siswa tersimpan: $idSiswa');
      } else {
        await prefs.remove('id_siswa');
        print('ID Siswa tidak ada atau tidak valid');
      }

      // Simpan id_kelas jika ada
      final idKelas = body['user']['id_kelas'] as int?;
      if (idKelas != null && idKelas != 0) {
        await prefs.setInt('id_kelas', idKelas);
        print('ID Kelas tersimpan: $idKelas');
      } else {
        await prefs.remove('id_kelas');
        print('ID Kelas tidak ada atau tidak valid');
      }

      return {
        'token': body['token'],
        'user': body['user'],
      };
    } else {
      throw Exception('Login gagal: ${resp.body}');
    }
  }
}
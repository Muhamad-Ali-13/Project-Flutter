import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();

  String? _nama;
  String? _email;
  String? _role;
  String? _password;

  bool _isLoading = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final nama = await _storage.read(key: 'nama');
    final email = await _storage.read(key: 'email');
    final role = await _storage.read(key: 'role');
    final password = await _storage.read(key: 'password');

    setState(() {
      _nama = nama ?? 'Tidak diketahui';
      _email = email ?? '-';
      _role = role ?? '-';
      _password = password ?? '-';
      _isLoading = false;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0700),
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar dengan shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Color(0xFFFF0700)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _nama ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFFFF0700)),
                    title: const Text('Email'),
                    subtitle: Text(_email ?? '-'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.verified_user, color: Color(0xFFFF0700)),
                    title: const Text('Role'),
                    subtitle: Text(_role ?? '-'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.password_outlined, color: Color(0xFFFF0700)),
                    title: const Text('Password'),
                    subtitle: Text(
                      _isPasswordVisible
                          ? (_password ?? '-')
                          : (_password != null ? '*' * _password!.length : '-'),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _logout,
                label: const Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0700),
                  foregroundColor: Colors.white, // teks jadi putih
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';

class EditUserPage extends StatefulWidget {
  final User user;
  const EditUserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedRole;
  bool _isSaving = false;

  final List<String> _roles = ['admin', 'guru', 'siswa'];

  Color get mainColor => Utils.mainThemeColor ?? Colors.red;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data termasuk role')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedUser = User(
        idUsers: widget.user.idUsers,
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        role: _selectedRole,
      );

      await ApiService.updateUser(updatedUser.idUsers, updatedUser.toJson());
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update user: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: mainColor),
      prefixIcon: Icon(icon, color: mainColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Utils.mainThemeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Nama
              TextFormField(
                controller: _namaController,
                decoration: _buildInputDecoration('Nama Lengkap', Icons.person),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email', Icons.email),
                validator: (value) =>
                value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                _buildInputDecoration('Kosongkan jika tidak diganti', Icons.lock),
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Role', Icons.security),
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) => value == null ? 'Pilih role' : null,
              ),
              const SizedBox(height: 32),

              Center(
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : AbsensiMainButton(
                  label: 'Simpan Perubahan',
                  onTap: _update,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

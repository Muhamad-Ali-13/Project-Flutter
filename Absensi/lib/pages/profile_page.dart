import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late Future<User> _futureUser;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void _loadUser() {
    _futureUser = ApiService.getCurrentUser().then((user) {
      print('User Profile Response: $user');
      _namaController.text = user.nama;
      _emailController.text = user.email;
      _passwordController.text = ''; // Password not shown; empty for updates
      return user;
    }).catchError((error) {
      print('User Profile Error: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: $error'),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: () => setState(_loadUser),
            ),
          ),
        );
      }
      throw error;
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _passwordController.clear(); // Clear password after cancel/save
      }
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _futureUser;

        final updatedData = {
          'nama': _namaController.text,
          'email': _emailController.text,
          if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
        };

        await ApiService.updateUser(user.idUsers, updatedData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        }

        setState(() {
          _isEditing = false;
          _loadUser(); // refresh data
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui profil: $e')),
          );
        }
      }
    }
  }


  void _logout() async {
    try {
      await ApiService.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: FutureBuilder<User>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gagal memuat profil: ${snapshot.error ?? "Data tidak tersedia"}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadUser),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Profil',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Nama',
                      controller: _namaController,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Password',
                      controller: _passwordController,
                      enabled: _isEditing,
                      obscureText: _obscurePassword,
                      suffixIcon: _isEditing
                          ? IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                          : null,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      placeholder: _isEditing ? 'Masukkan password baru (opsional)' : '******',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!_isEditing)
                          ElevatedButton(
                            onPressed: _toggleEdit,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
                          ),
                        if (_isEditing) ...[
                          TextButton(
                            onPressed: _toggleEdit,
                            child: const Text('Batal', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: enabled ? placeholder : null,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
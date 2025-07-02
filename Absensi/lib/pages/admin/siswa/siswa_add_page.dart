import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../services/api_service.dart';

class AddSiswaPage extends StatefulWidget {
  const AddSiswaPage({Key? key}) : super(key: key);

  @override
  State<AddSiswaPage> createState() => _AddSiswaPageState();
}

class _AddSiswaPageState extends State<AddSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _tanggallahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _kelas = [];
  String? _selectedUser;
  String? _selectedKelas;
  String? _selectedGender;
  bool _isLoading = true; // Added for loading state
  bool _isSaving = false;
  String? _errorMessage; // Added for error state

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      setState(() => _isLoading = true);

      final users = await ApiService.fetchUsers();
      final kelas = await ApiService.fetchKelas();

      if (mounted) {
        setState(() {
          // Validate and filter users
          _users = users
              .where((user) =>
          user is Map<String, dynamic> &&
              user['id_users'] != null &&
              user['nama'] != null)
              .toList();

          // Validate and filter kelas
          _kelas = kelas
              .where((kelas) =>
          kelas is Map<String, dynamic> &&
              kelas['id_kelas'] != null &&
              kelas['nama_kelas'] != null)
              .toList();

          // Set default values if lists are not empty
          if (_users.isNotEmpty &&
              (_selectedUser == null ||
                  !_users.any((user) => user['id_users'].toString() == _selectedUser))) {
            _selectedUser = _users.first['id_users'].toString();
          }
          if (_kelas.isNotEmpty &&
              (_selectedKelas == null ||
                  !_kelas.any((kelas) => kelas['id_kelas'].toString() == _selectedKelas))) {
            _selectedKelas = _kelas.first['id_kelas'].toString();
          }

          _isLoading = false;
          _errorMessage = null;

          // Debug print to check data
          print('Users: $_users');
          print('Kelas: $_kelas');
          print('Selected User: $_selectedUser');
          print('Selected Kelas: $_selectedKelas');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nisController.dispose();
    _tanggallahirController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 3650)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _tanggallahirController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final int? idUsers = int.tryParse(_selectedUser ?? '');
    final int? idKelas = int.tryParse(_selectedKelas ?? '');

    if (idUsers == null || idKelas == null || _selectedGender == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pastikan semua field terisi dengan benar')),
        );
      }
      return;
    }

    final tanggalLahir = _tanggallahirController.text.trim();
    if (DateTime.tryParse(tanggalLahir) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format Tanggal Lahir salah, harus YYYY-MM-DD')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final siswa = {
        'id_siswa': 0,
        'id_users': idUsers,
        'nis': _nisController.text.trim(),
        'tanggal_lahir': tanggalLahir,
        'alamat': _alamatController.text.trim(),
        'no_hp': _noHpController.text.trim().isEmpty ? null : _noHpController.text.trim(),
        'id_kelas': idKelas,
        'jenis_kelamin': _selectedGender,
      };

      await ApiService.createSiswa(siswa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan siswa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.red))
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Untuk Nama Siswa
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Nama Siswa', Icons.person),
                          value: _selectedUser,
                          items: _users.isEmpty
                              ? [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tidak ada data pengguna'),
                              enabled: false,
                            ),
                          ]
                              : _users.map((user) {
                            final id = user['id_users']?.toString() ?? '';
                            final nama = user['nama']?.toString() ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(nama),
                            );
                          }).toList(),
                          onChanged: _users.isEmpty
                              ? null
                              : (value) {
                            if (mounted) {
                              setState(() {
                                _selectedUser = value;
                                print('Selected User Changed: $_selectedUser');
                              });
                            }
                          },
                          validator: (value) =>
                          value == null ? 'Pilih nama user siswa' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Kelas', Icons.class_),
                          value: _selectedKelas,
                          items: _kelas.isEmpty
                              ? [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tidak ada data kelas'),
                              enabled: false,
                            ),
                          ]
                              : _kelas.map((kelas) {
                            final id = kelas['id_kelas']?.toString() ?? '';
                            final namaKelas =
                                kelas['nama_kelas']?.toString() ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(namaKelas),
                            );
                          }).toList(),
                          onChanged: _kelas.isEmpty
                              ? null
                              : (value) {
                            if (mounted) {
                              setState(() {
                                _selectedKelas = value;
                                print('Selected Kelas Changed: $_selectedKelas');
                              });
                            }
                          },
                          validator: (value) => value == null ? 'Pilih kelas' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nisController,
                          decoration:
                          _inputDecoration('NIS', Icons.confirmation_number),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'NIS harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tanggallahirController,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: _inputDecoration(
                              'Tanggal Lahir (YYYY-MM-DD)', Icons.date_range),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Tanggal Lahir harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _alamatController,
                          decoration: _inputDecoration('Alamat', Icons.home),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Alamat harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _noHpController,
                          decoration: _inputDecoration('No HP', Icons.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Jenis Kelamin', Icons.transgender),
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                          ],
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                _selectedGender = value;
                                print('Selected Gender Changed: $_selectedGender');
                              });
                            }
                          },
                          validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.red)
                    : AbsensiMainButton(label: 'Simpan', onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
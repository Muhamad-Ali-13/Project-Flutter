import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../models/siswa.dart';
import '../../../services/api_service.dart';

class EditSiswaPage extends StatefulWidget {
  final Siswa siswa;
  const EditSiswaPage({Key? key, required this.siswa}) : super(key: key);

  @override
  State<EditSiswaPage> createState() => _EditSiswaPageState();
}

class _EditSiswaPageState extends State<EditSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _kelas = [];
  String? _selectedUser;
  String? _selectedKelas;
  String? _selectedGender;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nisController.text = widget.siswa.nis;
    _tanggalLahirController.text =
        widget.siswa.tanggalLahir.toIso8601String().split('T').first;
    _alamatController.text = widget.siswa.alamat;
    _noHpController.text = widget.siswa.noHp ?? '';
    _selectedUser = widget.siswa.idUsers.toString();
    _selectedKelas = widget.siswa.idKelas.toString();

    // Konversi dari 'L'/'P' ke label yang ditampilkan
    _selectedGender = widget.siswa.jenisKelamin == 'L'
        ? 'Laki-laki'
        : widget.siswa.jenisKelamin == 'P'
        ? 'Perempuan'
        : null;

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      setState(() => _isLoading = true);
      final users = await ApiService.fetchUsers();
      final kelas = await ApiService.fetchKelas();

      if (mounted) {
        _users = users
            .where((user) =>
        user is Map<String, dynamic> &&
            user['id_users'] != null &&
            user['nama'] != null)
            .toList();

        _kelas = kelas
            .where((k) =>
        k is Map<String, dynamic> &&
            k['id_kelas'] != null &&
            k['nama_kelas'] != null)
            .toList();

        if (!_users.any((u) => u['id_users'].toString() == _selectedUser)) {
          _selectedUser =
          _users.isNotEmpty ? _users.first['id_users'].toString() : null;
        }
        if (!_kelas.any((k) => k['id_kelas'].toString() == _selectedKelas)) {
          _selectedKelas =
          _kelas.isNotEmpty ? _kelas.first['id_kelas'].toString() : null;
        }

        setState(() {
          _isLoading = false;
          _errorMessage = null;
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
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final currentText = _tanggalLahirController.text;
    final initialDate = currentText.isNotEmpty
        ? DateTime.tryParse(currentText) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _tanggalLahirController.text =
            picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final int? idUsers = int.tryParse(_selectedUser ?? '');
    final int? idKelas = int.tryParse(_selectedKelas ?? '');

    if (idUsers == null || idKelas == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua field terisi dengan benar')),
      );
      return;
    }

    final tanggalLahir = _tanggalLahirController.text.trim();
    if (DateTime.tryParse(tanggalLahir) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format Tanggal Lahir salah')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final siswa = {
        'id_siswa': widget.siswa.idSiswa,
        'id_users': idUsers,
        'nis': _nisController.text.trim(),
        'tanggal_lahir': tanggalLahir,
        'alamat': _alamatController.text.trim(),
        'no_hp': _noHpController.text.trim().isEmpty
            ? null
            : _noHpController.text.trim(),
        'id_kelas': idKelas,
        'jenis_kelamin':
        _selectedGender == 'Laki-laki' ? 'L' : 'P', // <-- Perbaikan di sini
      };

      debugPrint('Update payload: $siswa');

      await ApiService.updateSiswa(widget.siswa.idSiswa, siswa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update siswa: $e')),
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
        title: const Text('Edit Siswa'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.red),
          )
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
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration(
                              'Nama Siswa', Icons.person),
                          value: _selectedUser,
                          items: _users.map((user) {
                            return DropdownMenuItem<String>(
                              value: user['id_users'].toString(),
                              child:
                              Text(user['nama'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUser = value;
                            });
                          },
                          validator: (value) =>
                          value == null ? 'Pilih nama siswa' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration:
                          _inputDecoration('Kelas', Icons.class_),
                          value: _selectedKelas,
                          items: _kelas.map((kelas) {
                            return DropdownMenuItem<String>(
                              value: kelas['id_kelas'].toString(),
                              child: Text(kelas['nama_kelas'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKelas = value;
                            });
                          },
                          validator: (value) =>
                          value == null ? 'Pilih kelas' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nisController,
                          decoration: _inputDecoration(
                              'NIS', Icons.confirmation_number),
                          validator: (value) => value == null || value.isEmpty
                              ? 'NIS harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tanggalLahirController,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: _inputDecoration(
                              'Tanggal Lahir (YYYY-MM-DD)',
                              Icons.date_range),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Tanggal Lahir harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _alamatController,
                          decoration:
                          _inputDecoration('Alamat', Icons.home),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Alamat harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _noHpController,
                          decoration:
                          _inputDecoration('No HP', Icons.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration(
                              'Jenis Kelamin', Icons.transgender),
                          value: _selectedGender,
                          items: ['Laki-laki', 'Perempuan'].map((gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Pilih jenis kelamin'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.red)
                    : AbsensiMainButton(label: 'Update', onTap: _update),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

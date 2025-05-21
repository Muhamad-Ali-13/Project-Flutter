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
  final TextEditingController _idUsersController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _tanggallahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _idKelasController = TextEditingController();
  final TextEditingController _jenisKelaminController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _idUsersController.dispose();
    _nisController.dispose();
    _tanggallahirController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _idKelasController.dispose();
    _jenisKelaminController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final int? idUsers = int.tryParse(_idUsersController.text.trim());
    final int? idKelas = int.tryParse(_idKelasController.text.trim());

    if (idUsers == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Users harus berupa angka valid')),
      );
      return;
    }
    if (idKelas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Kelas harus berupa angka valid')),
      );
      return;
    }

    final tanggalLahir = _tanggallahirController.text.trim();
    if (tanggalLahir.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal Lahir harus diisi')),
      );
      return;
    }
    if (DateTime.tryParse(tanggalLahir) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format Tanggal Lahir salah, harus YYYY-MM-DD')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final siswa = {
        'id_siswa': 0,
        'id_users': idUsers,
        'nis': _nisController.text.trim(),
        'tanggal_lahir': tanggalLahir,  // Perbaikan key JSON
        'alamat': _alamatController.text.trim(),
        'no_hp': _noHpController.text.trim().isEmpty ? null : _noHpController.text.trim(),
        'id_kelas': idKelas,
        'jenis_kelamin': _jenisKelaminController.text.trim(),
      };

      await ApiService.createSiswa(siswa);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan siswa: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Utils.generateInputField(
                  hintText: 'Nama Siswa (ID Users)',
                  iconData: Icons.person,
                  controller: _idUsersController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) =>
                  value == null || value.isEmpty ? 'ID Users harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'NIS',
                  iconData: Icons.confirmation_number,
                  controller: _nisController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) => value == null || value.isEmpty ? 'NIS harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Tanggal Lahir (YYYY-MM-DD)',
                  iconData: Icons.date_range,
                  controller: _tanggallahirController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Tanggal Lahir harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Alamat',
                  iconData: Icons.home,
                  controller: _alamatController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) => value == null || value.isEmpty ? 'Alamat harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'No HP',
                  iconData: Icons.phone,
                  controller: _noHpController,
                  isPassword: false,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'ID Kelas',
                  iconData: Icons.class_,
                  controller: _idKelasController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) =>
                  value == null || value.isEmpty ? 'ID Kelas harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Jenis Kelamin',
                  iconData: Icons.transgender,
                  controller: _jenisKelaminController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Jenis Kelamin harus diisi' : null,
                ),
                const Spacer(),
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

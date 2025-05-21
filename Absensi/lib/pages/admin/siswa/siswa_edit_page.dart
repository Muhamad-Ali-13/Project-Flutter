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
  late TextEditingController _nisController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _noHpController;
  late TextEditingController _idKelasController;
  late TextEditingController _jenisKelaminController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(text: widget.siswa.nis);
    _tanggalLahirController = TextEditingController(text: widget.siswa.tanggalLahir.toIso8601String().split('T').first);
    _alamatController = TextEditingController(text: widget.siswa.alamat);
    _noHpController = TextEditingController(text: widget.siswa.noHp ?? '');
    _idKelasController = TextEditingController(text: widget.siswa.idKelas.toString());
    _jenisKelaminController = TextEditingController(text: widget.siswa.jenisKelamin);
  }

  @override
  void dispose() {
    _nisController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _idKelasController.dispose();
    _jenisKelaminController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final siswa = Siswa(
        idSiswa: widget.siswa.idSiswa,
        idUsers: widget.siswa.idUsers,
        nis: _nisController.text.trim(),
        tanggalLahir: DateTime.parse(_tanggalLahirController.text.trim()),
        alamat: _alamatController.text.trim(),
        noHp: _noHpController.text.trim(),
        idKelas: int.parse(_idKelasController.text.trim()),
        jenisKelamin: _jenisKelaminController.text.trim(),
        namaKelas: '',
        nama: '',
      );
      await ApiService.updateSiswa(siswa.idSiswa, siswa.toJson());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siswa berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update siswa: $e')),
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
        title: const Text('Edit Siswa'),
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
                  hintText: 'NIS',
                  iconData: Icons.badge,
                  controller: _nisController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) => value == null || value.isEmpty ? 'NIS harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Tanggal Lahir (YYYY-MM-DD)',
                  iconData: Icons.calendar_today,
                  controller: _tanggalLahirController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) => value == null || value.isEmpty ? 'Tanggal Lahir harus diisi' : null,
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
                  validator: (value) => value == null || value.isEmpty ? 'ID Kelas harus diisi' : null,
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Jenis Kelamin',
                  iconData: Icons.transgender,
                  controller: _jenisKelaminController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) => value == null || value.isEmpty ? 'Jenis Kelamin harus diisi' : null,
                ),
                const Spacer(),
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
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../services/api_service.dart';

class AddJadwalPembelajaranPage extends StatefulWidget {
  const AddJadwalPembelajaranPage({Key? key}) : super(key: key);

  @override
  State<AddJadwalPembelajaranPage> createState() => _AddJadwalPembelajaranPageState();
}

class _AddJadwalPembelajaranPageState extends State<AddJadwalPembelajaranPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idGuruController = TextEditingController();
  final TextEditingController _idKelasController = TextEditingController();
  final TextEditingController _idMapelController = TextEditingController();
  final TextEditingController _hariController = TextEditingController();
  final TextEditingController _jamMulaiController = TextEditingController();
  final TextEditingController _jamSelesaiController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _idGuruController.dispose();
    _idKelasController.dispose();
    _idMapelController.dispose();
    _hariController.dispose();
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final jadwal = {
        'id_guru': int.parse(_idGuruController.text.trim()),
        'id_kelas': int.parse(_idKelasController.text.trim()),
        'id_mapel': int.parse(_idMapelController.text.trim()),
        'hari': _hariController.text.trim(),
        'jam_mulai': _jamMulaiController.text.trim(),
        'jam_selesai': _jamSelesaiController.text.trim(),
      };
      await ApiService.createJadwalPembelajaran(jadwal);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jadwal: $e')),
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
        title: const Text('Tambah Jadwal Pembelajaran'),
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
            child: ListView(
              children: [
                Utils.generateInputField(
                  hintText: 'ID Guru (angka)',
                  iconData: Icons.person,
                  controller: _idGuruController,
                  isPassword: false,
                  onChanged: (_) {},
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID Guru harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ID Guru harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'ID Kelas (angka)',
                  iconData: Icons.class_,
                  controller: _idKelasController,
                  isPassword: false,
                  onChanged: (_) {},
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID Kelas harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ID Kelas harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'ID Mata Pelajaran (angka)',
                  iconData: Icons.book,
                  controller: _idMapelController,
                  isPassword: false,
                  onChanged: (_) {},
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID Mata Pelajaran harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ID Mata Pelajaran harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Hari (Senin - Sabtu)',
                  iconData: Icons.calendar_today,
                  controller: _hariController,
                  isPassword: false,
                  onChanged: (_) {},
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hari harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Jam Mulai (HH:mm:ss)',
                  iconData: Icons.schedule,
                  controller: _jamMulaiController,
                  isPassword: false,
                  onChanged: (_) {},
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jam Mulai harus diisi';
                    }
                    if (!RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(value.trim())) {
                      return 'Format Jam Mulai harus HH:mm:ss';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Utils.generateInputField(
                  hintText: 'Jam Selesai (HH:mm:ss)',
                  iconData: Icons.schedule,
                  controller: _jamSelesaiController,
                  isPassword: false,
                  onChanged: (_) {},
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jam Selesai harus diisi';
                    }
                    if (!RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(value.trim())) {
                      return 'Format Jam Selesai harus HH:mm:ss';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isSaving
                    ? const Center(child: CircularProgressIndicator(color: Colors.red))
                    : AbsensiMainButton(label: 'Simpan', onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
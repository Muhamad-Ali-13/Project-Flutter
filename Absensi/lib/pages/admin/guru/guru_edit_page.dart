import 'package:absensi/widgets/absensi_main_button.dart';
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../models/guru.dart';
import '../../../services/api_service.dart';

class EditGuruPage extends StatefulWidget {
  final Guru guru;
  const EditGuruPage({Key? key, required this.guru}) : super(key: key);

  @override
  State<EditGuruPage> createState() => _EditGuruPageState();
}

class _EditGuruPageState extends State<EditGuruPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nipController;
  late TextEditingController _noHpController;

  String? _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nipController = TextEditingController(text: widget.guru.nip);
    _noHpController = TextEditingController(text: widget.guru.noHp ?? '');

    // Konversi 'L'/'P' menjadi label
    _selectedGender = widget.guru.jenisKelamin == 'L'
        ? 'Laki-laki'
        : widget.guru.jenisKelamin == 'P'
        ? 'Perempuan'
        : null;
  }

  @override
  void dispose() {
    _nipController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black),
    );
  }

  Future<void> _updateGuru() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final updateData = {
        'nip': _nipController.text.trim(),
        'jenis_kelamin':
        _selectedGender == 'Laki-laki' ? 'L' : 'P', // <-- Perbaikan di sini
        'no_hp': _noHpController.text.trim().isEmpty
            ? null
            : _noHpController.text.trim(),
      };

      await ApiService.updateGuru(widget.guru.idGuru, updateData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guru berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update guru: $e')),
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
        title: const Text('Edit Guru'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nipController,
                  decoration: _inputDecoration(label: 'NIP', icon: Icons.badge),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'NIP harus diisi' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: _inputDecoration(
                    label: 'Jenis Kelamin',
                    icon: Icons.transgender,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Jenis Kelamin harus dipilih' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noHpController,
                  decoration:
                  _inputDecoration(label: 'No HP', icon: Icons.phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : AbsensiMainButton(label: 'Update', onTap: _updateGuru),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

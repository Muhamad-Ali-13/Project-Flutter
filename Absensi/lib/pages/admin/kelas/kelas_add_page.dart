import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../services/api_service.dart';

class AddKelasPage extends StatefulWidget {
  const AddKelasPage({Key? key}) : super(key: key);

  @override
  State<AddKelasPage> createState() => _AddKelasPageState();
}

class _AddKelasPageState extends State<AddKelasPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaKelasController = TextEditingController();
  final TextEditingController _waliKelasController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _namaKelasController.dispose();
    _waliKelasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final kelas = {
        'nama_kelas': _namaKelasController.text.trim(),
        'id_guru': int.tryParse(_waliKelasController.text.trim()) ?? null,
      };

      await ApiService.createKelas(kelas);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kelas berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan kelas: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (!optional && (value == null || value.trim().isEmpty)) {
          return '$label harus diisi';
        }
        if (isNumber && value != null && value.trim().isNotEmpty && int.tryParse(value) == null) {
          return '$label harus berupa angka';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kelas'),
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
                _buildInputField(
                  label: 'Nama Kelas',
                  icon: Icons.class_,
                  controller: _namaKelasController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'ID Wali Kelas (Opsional)',
                  icon: Icons.person,
                  controller: _waliKelasController,
                  isNumber: true,
                  optional: true,
                ),
                const SizedBox(height: 32),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.red)
                    : SizedBox(
                  width: double.infinity,
                  child: AbsensiMainButton(
                    label: 'Simpan',
                    onTap: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
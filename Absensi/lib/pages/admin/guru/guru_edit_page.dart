import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
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
  late TextEditingController _jenisKelaminController;
  late TextEditingController _noHpController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nipController = TextEditingController(text: widget.guru.nip);
    _jenisKelaminController = TextEditingController(text: widget.guru.jenisKelamin);
    _noHpController = TextEditingController(text: widget.guru.noHp ?? '');
  }

  @override
  void dispose() {
    _nipController.dispose();
    _jenisKelaminController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _updateGuru() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{};

      if (_nipController.text.trim() != widget.guru.nip) {
        updateData['nip'] = _nipController.text.trim();
      }

      if (_jenisKelaminController.text.trim() != widget.guru.jenisKelamin) {
        updateData['jenis_kelamin'] = _jenisKelaminController.text.trim();
      }

      final noHpTrimmed = _noHpController.text.trim();
      if (noHpTrimmed != (widget.guru.noHp ?? '')) {
        updateData['no_hp'] = noHpTrimmed.isEmpty ? null : noHpTrimmed;
      }

      if (updateData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada perubahan untuk disimpan')),
        );
        setState(() => _isSaving = false);
        return;
      }

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

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label harus diisi';
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
        title: const Text('Edit Guru'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  label: 'NIP',
                  icon: Icons.badge,
                  controller: _nipController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Jenis Kelamin',
                  icon: Icons.transgender,
                  controller: _jenisKelaminController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'No HP',
                  icon: Icons.phone,
                  controller: _noHpController,
                ),
                const SizedBox(height: 32),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.red)
                    : SizedBox(
                  width: double.infinity,
                  child: AbsensiMainButton(
                    label: 'Update',
                    onTap: _updateGuru,
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

import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../models/kelas.dart';
import '../../../services/api_service.dart';

class EditKelasPage extends StatefulWidget {
  final Kelas kelas;
  const EditKelasPage({Key? key, required this.kelas}) : super(key: key);

  @override
  State<EditKelasPage> createState() => _EditKelasPageState();
}

class _EditKelasPageState extends State<EditKelasPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaKelasController;

  List<Map<String, dynamic>> _guru = [];
  String? _selectedGuru;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _namaKelasController = TextEditingController(text: widget.kelas.namaKelas);
    _selectedGuru = widget.kelas.idGuru?.toString();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      setState(() => _isLoading = true);

      final guru = await ApiService.fetchGurus();
      setState(() {
        _guru = guru
            .where((g) =>
        g is Map<String, dynamic> &&
            g['id_guru'] != null &&
            g['nama'] != null)
            .toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data guru: $e';
      });
    }
  }

  @override
  void dispose() {
    _namaKelasController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final kelas = Kelas(
        idKelas: widget.kelas.idKelas,
        namaKelas: _namaKelasController.text.trim(),
        idGuru: _selectedGuru != null ? int.tryParse(_selectedGuru!) : null,
      );

      await ApiService.updateKelas(kelas.idKelas!, kelas.toJson());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kelas berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update kelas: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
        title: const Text('Edit Kelas'),
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
                        TextFormField(
                          controller: _namaKelasController,
                          decoration: _inputDecoration(
                              'Nama Kelas', Icons.class_),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Nama Kelas harus diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.red)
                    : SizedBox(
                  width: double.infinity,
                  child: AbsensiMainButton(
                    label: 'Update',
                    onTap: _update,
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

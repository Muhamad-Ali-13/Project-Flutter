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
  List<Map<String, dynamic>> _guru = [];
  String? _selectedGuru;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      setState(() => _isLoading = true);

      final guru = await ApiService.fetchGurus(); // Changed to singular fetchGuru

      if (mounted) {
        setState(() {
          // Validate and filter guru
          _guru = guru
              .where((guru) =>
          guru is Map<String, dynamic> &&
              guru['id_guru'] != null &&
              guru['nama'] != null)
              .toList();

          _isLoading = false;
          _errorMessage = null;

          // Debug print to check data
          print('Raw Guru Data: $guru');
          print('Filtered Guru: $_guru');
          print('Selected Guru: $_selectedGuru');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data guru: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaKelasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final kelas = {
        'nama_kelas': _namaKelasController.text.trim(),
        'id_guru': _selectedGuru != null ? int.tryParse(_selectedGuru!) : null,
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
                          decoration:
                          _inputDecoration('Nama Kelas', Icons.class_),
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
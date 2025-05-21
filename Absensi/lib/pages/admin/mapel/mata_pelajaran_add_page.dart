import 'package:flutter/material.dart';
import '../../../services/api_service.dart'; // Ganti dengan service yang sesuai
import '../../../utils/utils.dart';

class AddMataPelajaranPage extends StatefulWidget {
  const AddMataPelajaranPage({Key? key}) : super(key: key);

  @override
  State<AddMataPelajaranPage> createState() => _AddMataPelajaranPageState();
}

class _AddMataPelajaranPageState extends State<AddMataPelajaranPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaMapelController = TextEditingController();
  final TextEditingController _kodeMapelController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _namaMapelController.dispose();
    _kodeMapelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final mapel = {
        'nama': _namaMapelController.text.trim(),
        'kode': _kodeMapelController.text.trim(),
      };
      await ApiService.createMataPelajaran(mapel);
      Navigator.pop(context, true); // Kembali dan beri sinyal untuk menyegarkan halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan mata pelajaran: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Mata Pelajaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaMapelController,
                decoration: const InputDecoration(labelText: 'Nama Mata Pelajaran'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kodeMapelController,
                decoration: const InputDecoration(labelText: 'Kode Mata Pelajaran'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

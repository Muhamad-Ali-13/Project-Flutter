import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/absensi.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';

class EditAbsensiPage extends StatefulWidget {
  final Absensi absensi;
  const EditAbsensiPage({Key? key, required this.absensi}) : super(key: key);

  @override
  State<EditAbsensiPage> createState() => _EditAbsensiPageState();
}

class _EditAbsensiPageState extends State<EditAbsensiPage> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedStatus;
  late TextEditingController _keteranganController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.absensi.status;
    _keteranganController = TextEditingController(text: widget.absensi.keterangan);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      File? file = _imageFile != null ? File(_imageFile!.path) : null;
      await ApiService.updateAbsensi(
        id: widget.absensi.id,
        status: _selectedStatus,
        keterangan: _keteranganController.text.trim(),
        foto: file,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update absensi: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Absensi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Immutable fields (display only)
                ListTile(
                  title: const Text('Siswa'),
                  subtitle: Text(widget.absensi.namaSiswa ?? 'ID: ${widget.absensi.idSiswa}'),
                ),
                ListTile(
                  title: const Text('Kelas'),
                  subtitle: Text(widget.absensi.namaKelas ?? 'ID: ${widget.absensi.idKelas}'),
                ),
                ListTile(
                  title: const Text('Guru'),
                  subtitle: Text(widget.absensi.namaGuru ?? 'ID: ${widget.absensi.idGuru}'),
                ),
                ListTile(
                  title: const Text('Mata Pelajaran'),
                  subtitle: Text(widget.absensi.namaMapel ?? 'ID: ${widget.absensi.idMapel}'),
                ),
                ListTile(
                  title: const Text('Jadwal'),
                  subtitle: Text(widget.absensi.namaJadwal ?? 'ID: ${widget.absensi.idJadwal}'),
                ),
                ListTile(
                  title: const Text('Tanggal'),
                  subtitle: Text(Utils.formatTanggal(widget.absensi.tanggal)),
                ),
                ListTile(
                  title: const Text('Jam Masuk'),
                  subtitle: Text(widget.absensi.jamMasuk ?? 'N/A'),
                ),
                ListTile(
                  title: const Text('Jam Keluar'),
                  subtitle: Text(widget.absensi.jamKeluar ?? 'N/A'),
                ),
                // Editable fields
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: _selectedStatus,
                  items: ['Hadir', 'Izin', 'Sakit', 'Alfa'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                  validator: (val) => val == null ? 'Wajib dipilih' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keteranganController,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
                const SizedBox(height: 12),
                Text('Foto Absensi', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : widget.absensi.fotoAbsensi != null
                        ? Image.network(widget.absensi.fotoAbsensi!, fit: BoxFit.cover)
                        : const Center(child: Text('Ketuk untuk ambil foto')),
                  ),
                ),
                const SizedBox(height: 24),
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : AbsensiMainButton(label: 'Update', onTap: _update),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
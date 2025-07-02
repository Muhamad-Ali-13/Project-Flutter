// File: lib/pages/edit_absensi_page.dart
import 'package:flutter/material.dart';
import '../../../models/absensi.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class EditAbsensiPage extends StatefulWidget {
  final Absensi absensi;

  const EditAbsensiPage({Key? key, required this.absensi}) : super(key: key);

  @override
  State<EditAbsensiPage> createState() => _EditAbsensiPageState();
}

class _EditAbsensiPageState extends State<EditAbsensiPage> {
  final List<String> _statusList = ['Hadir', 'Izin', 'Sakit', 'Alfa', 'Bolos'];
  String? _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = _statusList.contains(widget.absensi.status)
        ? widget.absensi.status
        : null;
  }

  Future<void> _submit() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih status terlebih dahulu')),
      );
      return;
    }

    if (widget.absensi.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID absensi tidak valid')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.updateAbsensiStatus(
        id: widget.absensi.id!,
        status: _selectedStatus!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status absensi berhasil diperbarui')),
        );
        Navigator.pop(context, true); // Kembali dengan status berhasil
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final abs = widget.absensi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Absensi'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info('Nama Siswa', abs.nama_siswa ?? '-'),
            _info('Kelas', abs.nama_kelas ?? '-'),
            _info('Tanggal',
                abs.tanggal != null ? Utils.formatTanggal(abs.tanggal!) : '-'),
            _info('Jam Masuk', abs.jam_masuk ?? '-'),
            _info('Jam Keluar', abs.jam_keluar ?? '-'),
            const SizedBox(height: 16),
            const Text(
              'Ubah Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _statusList.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

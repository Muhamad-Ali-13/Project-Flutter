import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/absensi.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final _storage = const FlutterSecureStorage();
  String? _teacherName;
  String? _role;
  bool _isLoading = true;
  String? _errorMessage;
  List<Absensi> _allAbsensi = [];
  List<Absensi> _filteredAbsensi = [];
  List<String> _kelasList = [];
  String? _selectedKelas;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'token') ?? '';
      _role = await _storage.read(key: 'role') ?? '';
      _teacherName = await _storage.read(key: 'nama') ?? '';

      if (token.isEmpty || _role!.isEmpty) {
        _setError('Data sesi hilang. Silakan login ulang.');
        return;
      }
      if (_role != 'guru') {
        _setError('Akses hanya untuk guru. Role Anda: $_role. Silakan login ulang.');
        return;
      }

      await _fetchAbsensiList();
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAbsensiList() async {
    setState(() => _isLoading = true);
    try {
      final all = await ApiService.fetchAbsensi();

      final pending = all
          .where((a) =>
      a.keterangan?.toLowerCase().trim() == 'menunggu_verifikasi')
          .toList();

      final kelas = pending.map((a) => a.nama_kelas ?? '').toSet().toList();

      setState(() {
        _allAbsensi = pending;
        _kelasList = kelas;
        _selectedKelas = kelas.isNotEmpty ? kelas.first : null;
        _filterByKelas();
        _errorMessage = pending.isEmpty ? 'Belum ada absensi untuk diverifikasi' : null;
      });
    } catch (e) {
      _setError('Gagal memuat daftar absensi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterByKelas() {
    if (_selectedKelas == null) {
      _filteredAbsensi = [];
    } else {
      _filteredAbsensi = _allAbsensi
          .where((a) => a.nama_kelas == _selectedKelas)
          .toList();
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _allAbsensi = [];
        _filteredAbsensi = [];
      });
    }
  }

  Future<void> _verifyAbsensi(int absensiId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.verifyAbsensi(absensiId);
      if (response.statusCode == 200) {
        await _fetchAbsensiList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil diverifikasi.')),
        );
      } else {
        throw Exception('Gagal verifikasi: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Selamat Datang, ${_teacherName ?? 'Guru'}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Utils.mainThemeColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verifikasi Absensi Siswa',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedKelas,
                isExpanded: true,
                iconEnabledColor: Utils.mainThemeColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Pilih Kelas",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _kelasList.isEmpty
                    ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Tidak ada kelas"),
                  )
                ]
                    : _kelasList
                    .map((kelas) => DropdownMenuItem(
                  value: kelas,
                  child: Text(kelas),
                ))
                    .toList(),
                onChanged: _kelasList.isEmpty
                    ? null
                    : (kelas) {
                  setState(() {
                    _selectedKelas = kelas;
                    _filterByKelas();
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: _fetchAbsensiList,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Perbarui',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredAbsensi.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ??
                          'Tidak ada absensi untuk kelas ini.',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredAbsensi.length,
                itemBuilder: (context, index) {
                  final abs = _filteredAbsensi[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          '${abs.nama_siswa} - ${Utils.formatTanggal(abs.tanggal!)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Utils.mainThemeColor),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Kelas: ${abs.nama_kelas}'),
                            Text('Jam Masuk: ${abs.jam_masuk ?? '-'}'),
                            Text('Jam Keluar: ${abs.jam_keluar ?? '-'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () =>
                              _verifyAbsensi(abs.id!),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/absensi.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({Key? key}) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  late Future<List<Absensi>> _futureAbsensi;
  bool _isAdmin = true; // Replace with actual role check

  @override
  void initState() {
    super.initState();
    _loadAbsensi();
  }

  void _loadAbsensi() {
    _futureAbsensi = ApiService.fetchAbsensis(); // Tidak perlu mapping ulang
  }


  void _showDetailModal(Absensi absensi) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${absensi.status}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Siswa: ${absensi.namaSiswa ?? 'ID: ${absensi.idSiswa}'}'),
              Text('Kelas: ${absensi.namaKelas ?? 'ID: ${absensi.idKelas}'}'),
              Text('Guru: ${absensi.namaGuru ?? 'ID: ${absensi.idGuru}'}'),
              Text('Mata Pelajaran: ${absensi.namaMapel ?? 'ID: ${absensi.idMapel}'}'),
              Text('Jadwal: ${absensi.namaJadwal ?? 'ID: ${absensi.idJadwal}'}'),
              Text('Tanggal: ${Utils.formatTanggal(absensi.tanggal)}'),
              Text('Jam Masuk: ${absensi.jamMasuk ?? 'N/A'}'),
              Text('Jam Keluar: ${absensi.jamKeluar ?? 'N/A'}'),
              Text('Keterangan: ${absensi.keterangan ?? 'N/A'}'),
              if (absensi.fotoAbsensi != null) ...[
                const SizedBox(height: 8),
                Image.network(absensi.fotoAbsensi!, height: 100, fit: BoxFit.cover),
              ],
              if (_isAdmin) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/edit_absensi',
                          arguments: absensi,
                        ).then((refresh) {
                          if (refresh == true) setState(_loadAbsensi);
                        });
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(absensi.id);
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus absensi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteAbsensi(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Absensi berhasil dihapus')),
                  );
                  setState(_loadAbsensi);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus absensi: $e')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Absensi'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Absensi>>(
          future: _futureAbsensi,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gagal memuat data: ${snapshot.error ?? "Data tidak tersedia"}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadAbsensi),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            final absensiList = snapshot.data!;
            if (absensiList.isEmpty) {
              return const Center(child: Text('Belum ada data absensi.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: absensiList.length,
              itemBuilder: (context, index) {
                final absensi = absensiList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showDetailModal(absensi),
                    title: Text(
                      absensi.namaSiswa ?? 'Siswa ID: ${absensi.idSiswa}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${absensi.status} - ${Utils.formatTanggal(absensi.tanggal)}',
                    ),
                    trailing: Icon(Icons.event_available, color: Utils.mainThemeColor ?? Colors.red),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_absensi');
          if (result == true) setState(_loadAbsensi);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}
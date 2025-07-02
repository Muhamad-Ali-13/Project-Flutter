import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../../models/kelas.dart';
import '../../services/api_service.dart';

class AbsensiDetailPage extends StatefulWidget {
  final AbsensiHarian absensi;

  const AbsensiDetailPage({super.key, required this.absensi});

  @override
  State<AbsensiDetailPage> createState() => _AbsensiDetailPageState();
}

class _AbsensiDetailPageState extends State<AbsensiDetailPage> {
  List<Kelas> _kelasList = [];
  int? _selectedKelasId;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    try {
      final kelasMapList = await ApiService.fetchKelas();
      final kelas = kelasMapList.map((e) => Kelas.fromJson(e)).toList();
      setState(() {
        _kelasList = kelas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data kelas: $e')),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'sakit':
        return Colors.blue;
      case 'alpa':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'izin':
        return Icons.info;
      case 'sakit':
        return Icons.local_hospital;
      case 'alpa':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final absensi = widget.absensi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Absensi'),
        backgroundColor: const Color.fromARGB(255, 255, 7, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Filter Kelas
            DropdownButtonFormField<int>(
              value: _selectedKelasId,
              decoration: InputDecoration(
                labelText: 'Filter Kelas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua')),
                ..._kelasList.map((kelas) => DropdownMenuItem(
                  value: kelas.idKelas,
                  child: Text(kelas.namaKelas),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedKelasId = value;
                  // Di sini kamu bisa fetch ulang data absensi berdasarkan kelas jika tersedia
                });
              },
            ),
            const SizedBox(height: 16),

            // Dummy Absensi Card (ganti dengan loop jika datanya banyak)
            Expanded(
              child: ListView.builder(
                itemCount: 1, // ganti jika punya banyak data absensi
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(getStatusIcon(absensi.status),
                          color: getStatusColor(absensi.status), size: 36),
                      title: Text(
                        "Tanggal: ${absensi.tanggal}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Jumlah: ${absensi.total} siswa"),
                          Text(
                            "Status: ${absensi.status}",
                            style: TextStyle(color: getStatusColor(absensi.status)),
                          ),
                        ],
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

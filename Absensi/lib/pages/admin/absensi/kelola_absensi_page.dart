import 'dart:io';
import 'package:absensi/pages/admin/absensi/edit_absensi_page.dart';
import 'package:absensi/utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../../models/absensi.dart';
import 'package:absensi/models/kelas.dart';
import '../../../services/api_service.dart';
import 'package:absensi/utils/utils.dart';

class KelolaAbsensiPage extends StatefulWidget {
  const KelolaAbsensiPage({Key? key}) : super(key: key);

  @override
  State<KelolaAbsensiPage> createState() => _KelolaAbsensiPageState();
}

class _KelolaAbsensiPageState extends State<KelolaAbsensiPage> {
  late Future<List<Absensi>> _futureAbsensi;
  List<Kelas> _kelasList = [];
  int? _kelasFilterId;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAbsensi();
    _loadKelas();
  }

  void _loadAbsensi({int? kelasId}) {
    setState(() {
      _futureAbsensi = ApiService.fetchAbsensi().catchError((error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat absensi: $error'),
              action: SnackBarAction(
                label: 'Coba Lagi',
                onPressed: () => setState(() => _loadAbsensi(kelasId: kelasId)),
              ),
            ),
          );
        }
        return <Absensi>[];
      });
    });
  }

  void _loadKelas() async {
    try {
      final kelasMapList = await ApiService.fetchKelas();
      final kelas = kelasMapList.map((e) => Kelas.fromJson(e)).toList();
      setState(() {
        _kelasList = kelas;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kelas: $e')),
        );
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus absensi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
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
              setState(() => _isLoading = false);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(Absensi absensi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Wrap(
            runSpacing: 12,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Detail Absensi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 20),

              _buildInfoRow(Icons.person, 'Nama Siswa', absensi.nama_siswa ?? 'N/A'),
              _buildInfoRow(Icons.class_, 'Kelas', absensi.nama_kelas ?? 'N/A'),
              _buildInfoRow(Icons.date_range, 'Tanggal',
                  absensi.tanggal != null ? Utils.formatTanggal(absensi.tanggal!) : 'N/A'),
              _buildInfoRow(Icons.login, 'Jam Masuk', absensi.jam_masuk ?? '-'),
              _buildInfoRow(Icons.logout, 'Jam Keluar', absensi.jam_keluar ?? '-'),
              _buildInfoRow(Icons.info_outline, 'Status', absensi.status ?? '-'),
              _buildInfoRow(Icons.note_alt, 'Keterangan', absensi.keterangan ?? '-'),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                  // ElevatedButton.icon(
                  //   icon: const Icon(Icons.edit),
                  //   label: const Text('Edit'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Utils.mainThemeColor,
                  //     foregroundColor: Colors.white,
                  //   ),
                  //   onPressed: () {
                  //     Navigator.pop(context); // Tutup modal
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => EditAbsensiPage(absensi: absensi),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  Future<void> _cetakPdf() async {
    setState(() => _isLoading = true);
    try {
      final absensiList = await _futureAbsensi;
      // Terapkan filter
      final filtered = absensiList.where((a) {
        final matchKelas = _kelasFilterId == null ||
            a.id_kelas == _kelasFilterId;
        final matchDate = _selectedDate == null ||
            (a.tanggal != null &&
                Utils.sameDate(a.tanggal!, _selectedDate!));
        return matchKelas && matchDate;
      }).toList();

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada data yang dapat dicetak.')),
        );
        return;
      }

      // Judul filter
      final kelasName = _kelasFilterId == null
          ? 'Semua Kelas'
          : _kelasList
          .firstWhere((k) => k.idKelas == _kelasFilterId)
          .namaKelas;
      final filterTitle = _selectedDate == null
          ? 'Semua Tanggal'
          : 'Tanggal: ${Utils.formatTanggal(_selectedDate!)}';

      // Generate PDF bytes
      final pdfBytes = await PdfGenerator.generateAbsensiReport(
        data: filtered,
        filterTitle: filterTitle,
        namaKelas: kelasName,
      );

      // Minta izin (Scoped Storage Android 10+ tidak perlu WRITE_EXTERNAL_STORAGE)
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text('Izin penyimpanan ditolak. Tidak dapat menyimpan PDF.')),
          );
          return;
        }
      }

      // Simpan ke direktori aplikasi (Android/iOS)
      final dir = await getExternalStorageDirectory();
      final path = '${dir?.path}/laporan_absensi_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF berhasil disimpan di:\n$path')),
      );

      // Buka otomatis
      await OpenFile.open(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Absensi'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Cetak PDF',
            onPressed: _cetakPdf,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _kelasFilterId,
                      decoration: InputDecoration(
                        hintText: 'Pilih Kelas',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua')),
                        ..._kelasList.map(
                              (kelas) => DropdownMenuItem(
                            value: kelas.idKelas,
                            child: Text(kelas.namaKelas),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _kelasFilterId = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _selectedDate == null
                            ? 'Filter Tanggal'
                            : Utils.formatTanggal(_selectedDate!),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Absensi>>(
                future: _futureAbsensi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(child: Text('Gagal memuat data absensi.'));
                  }

                  final filtered = snapshot.data!.where((a) {
                    final matchKelas = _kelasFilterId == null || a.id_kelas == _kelasFilterId;
                    final matchDate = _selectedDate == null || (a.tanggal != null && Utils.sameDate(a.tanggal!, _selectedDate!));
                    return matchKelas && matchDate;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Tidak ada data absensi.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final absensi = filtered[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            absensi.nama_siswa ?? 'Siswa ID: ${absensi.id_siswa ?? 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${absensi.status ?? 'N/A'} - ${absensi.tanggal != null ? Utils.formatTanggal(absensi.tanggal!) : 'N/A'}',
                          ),
                          onTap: () => _showDetailModal(absensi),
                        ),
                      );
                    },
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
Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Utils.mainThemeColor, size: 22),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    ],
  );
}

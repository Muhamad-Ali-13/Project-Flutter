import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../models/absensi.dart';
import '../../../services/api_service.dart';
import '../../../utils/pdf_generator.dart';

class KelolaAbsensiPage extends StatefulWidget {
  const KelolaAbsensiPage({Key? key}) : super(key: key);

  @override
  State<KelolaAbsensiPage> createState() => _KelolaAbsensiPageState();
}

class _KelolaAbsensiPageState extends State<KelolaAbsensiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterMode = 'Mingguan';
  DateTime? _selectedDate;
  String? _selectedKelas;
  List<String> _kelasList = [];

  final String idGuru = '123'; // TODO: Ganti dengan ID guru dari login

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    final kelas = await ApiService.fetchKelasByGuru(idGuru);
    setState(() {
      _kelasList = kelas.map((k) => k['nama_kelas'] as String).toList();
    });
  }

  void _cetakPdf(List<Absensi> data) async {
    final namaKelas = _selectedKelas ?? 'Semua Kelas';
    final filterTitle = _filterMode == 'Mingguan'
        ? 'Minggu ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'
        : 'Bulan ${DateFormat('MMMM yyyy').format(_selectedDate!)}';

    final pdf = await PdfGenerator.generateAbsensiReport(
      data: data,
      filterTitle: filterTitle,
      namaKelas: namaKelas,
    );
    await Printing.layoutPdf(onLayout: (_) => pdf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filter Absensi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: const Text('Pilih Kelas'),
                  value: _selectedKelas,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua')),
                    ..._kelasList.map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas))),
                  ],
                  onChanged: (val) => setState(() => _selectedKelas = val),
                ),
                DropdownButton<String>(
                  value: _filterMode,
                  items: const [
                    DropdownMenuItem(value: 'Mingguan', child: Text('Mingguan')),
                    DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
                  ],
                  onChanged: (val) => setState(() => _filterMode = val!),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDate == null
                        ? 'Pilih Tanggal'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari siswa/status',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: FutureBuilder<List<Absensi>>(
                future: ApiService.fetchAbsensi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];
                  final filtered = data.where((absensi) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        (absensi.namaSiswa?.toLowerCase().contains(_searchQuery) ?? false);
                    final matchesKelas = _selectedKelas == null || absensi.namaKelas == _selectedKelas;

                    final matchesTanggal = () {
                      if (_selectedDate == null) return true;

                      final now = _selectedDate!;
                      final tanggalAbsensi = absensi.tanggal;

                      if (_filterMode == 'Mingguan') {
                        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                        final endOfWeek = startOfWeek.add(const Duration(days: 6));
                        return tanggalAbsensi.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                            tanggalAbsensi.isBefore(endOfWeek.add(const Duration(days: 1)));
                      } else {
                        return tanggalAbsensi.month == now.month &&
                            tanggalAbsensi.year == now.year;
                      }
                    }();

                    return matchesSearch && matchesKelas && matchesTanggal;
                  }).toList();





                  if (filtered.isEmpty) {
                    return const Center(child: Text('Tidak ada data sesuai filter.'));
                  }

                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _cetakPdf(filtered),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Cetak PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final a = filtered[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(a.namaSiswa ?? 'Siswa ID: ${a.idSiswa}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal: ${DateFormat('dd-MM-yyyy').format(a.tanggal)}'),
                                    Text('Status: ${a.status}'),
                                    Text('Mata Pelajaran: ${a.namaMapel ?? '-'}'),
                                    if (a.namaKelas != null) Text('Kelas: ${a.namaKelas}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

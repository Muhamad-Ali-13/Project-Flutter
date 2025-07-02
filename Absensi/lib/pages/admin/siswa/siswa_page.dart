import 'package:flutter/material.dart';
import '../../../models/siswa.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class SiswaPage extends StatefulWidget {
  const SiswaPage({Key? key}) : super(key: key);

  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> {
  late Future<List<Siswa>> _futureSiswa;

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  void _loadSiswa() {
    setState(() {
      _futureSiswa = ApiService.fetchSiswas().then(
            (list) => list.map((e) => Siswa.fromJson(e as Map<String, dynamic>)).toList(),
      ).catchError((error) {
        print('Error fetching siswa: $error');
        return <Siswa>[];
      });
    });
  }

  void _showDetailModal(Siswa siswa) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    siswa.nama,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _detailCard('Kelas', siswa.namaKelas ?? '-'),
                _detailCard('No HP', siswa.noHp ?? '-'),
                _detailCard('Alamat', siswa.alamat ?? '-'),
                _detailCard('Jenis Kelamin', siswa.jenisKelamin ?? '-'),
                _detailCard('Tanggal Lahir', Utils.formatTanggal(siswa.tanggalLahir)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/edit_siswa',
                          arguments: siswa,
                        ).then((refresh) {
                          if (refresh == true) setState(_loadSiswa);
                        });
                      },
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(siswa.idSiswa);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Utils.mainThemeColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailCard(String label, String value) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus siswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteSiswa(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Siswa berhasil dihapus')),
                  );
                }
                setState(_loadSiswa);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus siswa: $e')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Utils.mainThemeColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Utils.mainThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Siswa>>(
          future: _futureSiswa,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text('Error: ${snapshot.error ?? "Data tidak tersedia"}'));
            }
            final siswaList = snapshot.data!;
            if (siswaList.isEmpty) {
              return const Center(child: Text('Belum ada data siswa.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: siswaList.length,
              itemBuilder: (context, i) {
                final siswa = siswaList[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showDetailModal(siswa),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFC221C), Color(0xFFFF0000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siswa.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelas: ${siswa.namaKelas}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No HP: ${siswa.noHp ?? '-'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_siswa');
          if (result == true) _loadSiswa();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/kelas.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class KelasPage extends StatefulWidget {
  const KelasPage({Key? key}) : super(key: key);

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  late Future<List<Kelas>> _futureKelas;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  void _loadKelas() {
    _futureKelas = ApiService.fetchKelas().then(
          (list) => list.map((e) => Kelas.fromJson(e)).toList(),
    ).catchError((error) {
      print('Error fetching kelas: $error');
      return <Kelas>[];
    });
  }

  void _showDetailModal(Kelas kelas) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.class_, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kelas.namaKelas,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wali Kelas: ${kelas.namaGuru ?? 'Belum ada wali kelas'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/edit_kelas',
                        arguments: kelas,
                      ).then((refresh) {
                        if (refresh == true) setState(_loadKelas);
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(kelas.idKelas);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ],
              ),
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
        content: const Text('Apakah Anda yakin ingin menghapus kelas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteKelas(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelas berhasil dihapus')),
                  );
                }
                setState(_loadKelas);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus kelas: $e')),
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

  Widget _buildGradientCard(Kelas kelas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            (Utils.mainThemeColor ?? Colors.red).withOpacity(0.8),
            (Utils.mainThemeColor ?? Colors.red).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (Utils.mainThemeColor ?? Colors.red).withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 8,
          )
        ],
      ),
      child: ListTile(
        onTap: () => _showDetailModal(kelas),
        title: Text(
          kelas.namaKelas,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'Wali Kelas: ${kelas.namaGuru ?? 'Belum ada'}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Icon(Icons.class_, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kelas'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Kelas>>(
          future: _futureKelas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text('Error: ${snapshot.error ?? "Data tidak tersedia"}'),
              );
            }
            final kelasList = snapshot.data!;
            if (kelasList.isEmpty) {
              return const Center(child: Text('Belum ada data kelas.'));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                itemCount: kelasList.length,
                itemBuilder: (context, index) {
                  final kelas = kelasList[index];
                  return _buildGradientCard(kelas);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_kelas');
          if (result == true) setState(_loadKelas);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// lib/pages/mata_pelajaran_page.dart
import 'package:flutter/material.dart';
import '../../../models/mata_pelajaran.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class MataPelajaranPage extends StatefulWidget {
  const MataPelajaranPage({Key? key}) : super(key: key);

  @override
  State<MataPelajaranPage> createState() => _MataPelajaranPageState();
}

class _MataPelajaranPageState extends State<MataPelajaranPage> {
  late Future<List<MataPelajaran>> _futureMapel;

  @override
  void initState() {
    super.initState();
    _loadMataPelajaran();
  }

  void _loadMataPelajaran() {
    _futureMapel = ApiService.fetchMataPelajarans().then(
          (list) => list.map((e) => MataPelajaran.fromJson(e)).toList(),
    );
  }

  void _showDetailModal(MataPelajaran mapel) {
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
                mapel.namaMapel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/edit_mapel',
                        arguments: mapel,
                      ).then((refresh) {
                        if (refresh == true) setState(_loadMataPelajaran);
                      });
                    },
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(mapel.idMapel);
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
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
        content: const Text(
          'Apakah Anda yakin ingin menghapus mata pelajaran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deleteMataPelajaran(id);
              setState(_loadMataPelajaran);
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
        title: const Text('Mata Pelajaran'),
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
      body: FutureBuilder<List<MataPelajaran>>(
        future: _futureMapel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final mapelList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mapelList.length,
            itemBuilder: (context, index) {
              final mapel = mapelList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => _showDetailModal(mapel),
                  title: Text(
                    mapel.namaMapel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.menu_book),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_mapel');
          if (result == true) setState(_loadMataPelajaran);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

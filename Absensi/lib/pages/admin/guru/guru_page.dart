import 'package:flutter/material.dart';
import '../../../models/guru.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class GuruPage extends StatefulWidget {
  const GuruPage({Key? key}) : super(key: key);

  @override
  State<GuruPage> createState() => _GuruPageState();
}

class _GuruPageState extends State<GuruPage> {
  late Future<List<Guru>> _futureGuru;

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  void _loadGuru() {
    _futureGuru = ApiService.fetchGurus().then(
          (list) => list.map((e) => Guru.fromJson(e)).toList(),
    ).catchError((error) {
      print('Error fetching gurus: $error');
      return <Guru>[];
    });
  }

  void _showDetailModal(Guru guru) {
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
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person, size: 32, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guru.nama,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.badge, 'NIP', guru.nip),
              _buildDetailRow(Icons.wc, 'Jenis Kelamin', guru.jenisKelamin),
              if (guru.noHp != null && guru.noHp!.isNotEmpty)
                _buildDetailRow(Icons.phone, 'No HP', guru.noHp!),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/edit_guru',
                        arguments: guru,
                      ).then((refresh) {
                        if (refresh == true) setState(_loadGuru);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(guru.idGuru);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper untuk membangun satu baris detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus guru ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteGuru(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Guru berhasil dihapus')),
                );
                setState(_loadGuru);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus guru: $e')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard(Guru guru) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => _showDetailModal(guru),
        title: Text(
          guru.nama,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          guru.noHp?.isNotEmpty == true
              ? 'No HP: ${guru.noHp}'
              : 'No HP tidak tersedia',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Guru'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Guru>>(
          future: _futureGuru,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return Center(
                  child: Text('Error: ${snapshot.error ?? "Data tidak tersedia"}'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data guru'));
            }

            final guruList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: guruList.length,
              itemBuilder: (context, index) {
                final guru = guruList[index];
                return _buildGradientCard(guru);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_guru');
          if (result == true) setState(_loadGuru);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

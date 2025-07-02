import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<User>> _futureUsers;
  bool _isAdmin = false;

  Color get mainColor => Utils.mainThemeColor ?? Colors.red;
  // Membuat warna gradasi menggunakan mainColor, fallback ke red.shadeXXX
  List<Color> get gradientColors {
    if (Utils.mainThemeColor != null) {
      return [
        Utils.mainThemeColor!.withOpacity(0.9),
        Utils.mainThemeColor!.withOpacity(0.7),
      ];
    } else {
      return [
        Colors.red.shade900,
        Colors.red.shade700,
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadUsers();
  }

  void _checkUserRole() {
    _isAdmin = true; // contoh sementara
  }

  void _loadUsers() {
    _futureUsers = ApiService.fetchUsers().then(
          (list) {
        print('Users API Response: $list');
        return list.map((e) => User.fromJson(e)).toList();
      },
    ).catchError((error) {
      print('Users API Error: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pengguna: $error'),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: () => setState(_loadUsers),
            ),
          ),
        );
      }
      return <User>[];
    });
  }

  void _showDetailModal(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 36, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),

                // Informasi Role
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.security, size: 20, color: Colors.black54),
                    const SizedBox(width: 10),
                    const Text(
                      'Role:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(user.role ?? 'N/A'),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),

                // Tombol Aksi (Admin)
                if (_isAdmin) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/edit_user',
                            arguments: user,
                          ).then((refresh) {
                            if (refresh == true) setState(_loadUsers);
                          });
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('Edit'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete(user.idUsers);
                        },
                        icon: const Icon(Icons.delete, size: 20),
                        label: const Text('Hapus'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
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
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteUser(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pengguna berhasil dihapus')),
                  );
                }
                setState(_loadUsers);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus pengguna: $e')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text('Hapus', style: TextStyle(color: mainColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<User>>(
          future: _futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gagal memuat data: ${snapshot.error ?? "Data tidak tersedia"}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadUsers),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            final users = snapshot.data!;
            if (users.isEmpty) {
              return const Center(child: Text('Belum ada data user.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () => _showDetailModal(user),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.red),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user.role ?? 'Tanpa Role',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_user');
          if (result == true) setState(_loadUsers);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}

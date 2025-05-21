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
        Utils.mainThemeColor!.withOpacity(0.5),
      ];
    } else {
      return [
        Colors.red.shade900,
        Colors.red.shade700,
        Colors.red.shade400,
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
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 30, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.nama,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Icons.security, size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    'Role: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(user.role ?? 'N/A'),
                ],
              ),
              if (_isAdmin) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(user.idUsers);
                      },
                      icon: Icon(Icons.delete, size: 18, color: mainColor),
                      label: Text(
                        'Hapus',
                        style: TextStyle(color: mainColor),
                      ),
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

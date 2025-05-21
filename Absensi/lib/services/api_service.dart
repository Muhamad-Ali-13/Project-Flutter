// api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:absensi/models/dashboard.dart';
import 'package:http/http.dart' as http;
import '../models/absensi.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


// ==================== UTILS ====================

// Header JSON + optional Authorization
Map<String, String> _headers([String? token]) {
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  return headers;
}

// Generic GET list
Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http
      .get(url, headers: _headers())
      .timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

// Generic GET single item
Future<Map<String, dynamic>> fetchOne(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http
      .get(url, headers: _headers())
      .timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

// Generic POST / PUT / DELETE
Future<void> sendData(
  String method,
  String endpoint, {
  Map<String, dynamic>? body,
}) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final encoded = body == null ? null : jsonEncode(body);
  late http.Response resp;

  switch (method) {
    case 'POST':
      resp = await http
          .post(url, headers: _headers(), body: encoded)
          .timeout(const Duration(seconds: 10));
      break;
    case 'PUT':
      resp = await http
          .put(url, headers: _headers(), body: encoded)
          .timeout(const Duration(seconds: 10));
      break;
    case 'DELETE':
      resp = await http
          .delete(url, headers: _headers())
          .timeout(const Duration(seconds: 10));
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }

  if (resp.statusCode >= 400) {
    final msg =
        resp.body.isNotEmpty
            ? (jsonDecode(resp.body) as Map<String, dynamic>)['error'] ??
                resp.statusCode
            : resp.statusCode;
    throw Exception('$method $endpoint failed: $msg');
  }
}

// Upload File
Future<void> uploadFile(String endpoint, File file) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  final resp = await request.send().timeout(const Duration(seconds: 10));
  if (resp.statusCode != 200) {
    throw Exception('Upload failed: ${resp.statusCode}');
  }
}

// ==================== AUTH ====================
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/login');
  final resp = await http
      .post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      )
      .timeout(const Duration(seconds: 10));

  if (resp.statusCode == 200) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return {
      'token': body['token'],
      'user': body['user'],
    };
  } else {
    final body = jsonDecode(resp.body);
    throw Exception(body['error'] ?? 'Login gagal');
  }
}

Future<void> logout() async {
  final url = Uri.parse('$baseUrl/logout');
  final resp = await http
      .post(url, headers: _headers())
      .timeout(const Duration(seconds: 10));
  if (resp.statusCode != 200) {
    throw Exception('Logout failed: ${resp.statusCode}');
  }
}

// ==================== API SERVICE ====================

class ApiService {

  static Future<List<Map<String, dynamic>>> fetchKelasByGuru(String idGuru) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas?guru_id=$idGuru'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal memuat data kelas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  // USER
  static Future<List<User>> getUsersByGuru() async {
    final response = await http.get(Uri.parse('$baseUrl/users?role=guru'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat user dengan role guru');
    }
  }


  static Future<List<Map<String, dynamic>>> fetchUsers() async =>
      fetchData('users');

  static Future<Map<String, dynamic>> fetchUserById(int id_users) async =>
      fetchOne('users/$id_users');

  static Future<void> createUser(Map<String, dynamic> data) async =>
      sendData('POST', 'users', body: data);

  static Future<void> updateUser(int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui profil');
    }
  }



  static Future<void> deleteUser(int id_users) async =>
      sendData('DELETE', 'users/$id_users');

  static Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    return User(idUsers: 1, nama: 'nama', email: 'email', role: 'role');
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    print('Logged out');
  }

  // SISWA
  static Future<List<Map<String, dynamic>>> fetchSiswas() async =>
      fetchData('siswa');
  static Future<Map<String, dynamic>> fetchSiswaById(int id) async =>
      fetchOne('siswa/$id');
  static Future<void> createSiswa(Map<String, dynamic> siswa) async {
    final response = await http.post(
      Uri.parse('$baseUrl/siswa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(siswa),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambahkan siswa: ${response.body}');
    }
  }
  static Future<void> updateSiswa(int id, Map<String, dynamic> data) async =>
      sendData('PUT', 'siswa/$id', body: data);
  static Future<void> deleteSiswa(int id) async =>
      sendData('DELETE', 'siswa/$id');

  // GURU
  static Future<List<Map<String, dynamic>>> fetchGurus() async =>
      fetchData('guru');
  static Future<Map<String, dynamic>> fetchGuruById(int id) async =>
      fetchOne('guru/$id');
  static Future<void> createGuru(Map<String, dynamic> data) async =>
      sendData('POST', 'guru', body: data);
  static Future<void> updateGuru(int idGuru, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/guru/$idGuru');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // tambahkan auth header jika perlu
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update guru: ${response.body}');
    }
  }
  static Future<void> deleteGuru(int id) async =>
      sendData('DELETE', 'guru/$id');



  // KELAS
  static Future<List<Map<String, dynamic>>> fetchKelas() async =>
      fetchData('kelas');
  static Future<Map<String, dynamic>> fetchKelasById(int id) async =>
      fetchOne('kelas/$id');
  static Future<void> createKelas(Map<String, dynamic> data) async =>
      sendData('POST', 'kelas', body: data);
  static Future<void> updateKelas(int id, Map<String, dynamic> data) async =>
      sendData('PUT', 'kelas/$id', body: data);
  static Future<void> deleteKelas(int id) async =>
      sendData('DELETE', 'kelas/$id');

  // MATA PELAJARAN
  static Future<List<Map<String, dynamic>>> fetchMataPelajarans() async =>
      fetchData('mata_pelajaran');
  static Future<Map<String, dynamic>> fetchMataPelajaranById(int id) async =>
      fetchOne('mata_pelajaran/$id');
  static Future<void> createMataPelajaran(Map<String, dynamic> data) async =>
      sendData('POST', 'mata_pelajaran', body: data);
  static Future<void> updateMataPelajaran(
    int id,
    Map<String, dynamic> data,
  ) async => sendData('PUT', 'mata_pelajaran/$id', body: data);
  static Future<void> deleteMataPelajaran(int id) async =>
      sendData('DELETE', 'mata_pelajaran/$id');

  // JADWAL PEMBELAJARAN
  static Future<List<Map<String, dynamic>>> fetchJadwalPembelajarans() async =>
      fetchData('jadwalpembelajaran');
  static Future<Map<String, dynamic>> fetchJadwalPembelajaranById(
    int id,
  ) async => fetchOne('jadwalpembelajaran/$id');
  static Future<void> createJadwalPembelajaran(
    Map<String, dynamic> data,
  ) async => sendData('POST', 'jadwalpembelajaran', body: data);
  static Future<void> updateJadwalPembelajaran(
    int id,
    Map<String, dynamic> data,
  ) async => sendData('PUT', 'jadwalpembelajaran/$id', body: data);
  static Future<void> deleteJadwalPembelajaran(int id) async =>
      sendData('DELETE', 'jadwalpembelajaran/$id');


  /// Mendapatkan daftar absensi
  static Future<List<Absensi>> fetchAbsensi() async {
  final response = await http.get(Uri.parse('$baseUrl/absensi'));

  if (response.statusCode == 200) {
  final List<dynamic> data = jsonDecode(response.body);
  return data.map((json) => Absensi.fromJson(json)).toList();
  } else {
  throw Exception('Gagal mengambil data absensi: ${response.body}');
  }
  }

  /// Membuat absensi baru
  static Future<void> createAbsensi({
    required int idSiswa,
    required int idKelas,
    required int idGuru,
    required int idMapel,
    required int idJadwal,
    required String tanggal,
    String? jamMasuk,
    String? jamKeluar,
    required String status,
    required String keterangan,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/absensi'); // pastikan URL benar
    final request = http.MultipartRequest('POST', uri);

    request.fields['id_siswa'] = idSiswa.toString();
    request.fields['id_kelas'] = idKelas.toString();
    request.fields['id_guru'] = idGuru.toString();
    request.fields['id_mapel'] = idMapel.toString();
    request.fields['id_jadwal'] = idJadwal.toString();
    request.fields['tanggal'] = tanggal;
    if (jamMasuk != null) request.fields['jam_masuk'] = jamMasuk;
    if (jamKeluar != null) request.fields['jam_keluar'] = jamKeluar;
    request.fields['status'] = status;
    request.fields['keterangan'] = keterangan;

    if (foto != null) {
      final mimeType = lookupMimeType(foto.path);
      final fileStream = await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
      );
      request.files.add(fileStream);
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Gagal menyimpan absensi: ${response.statusCode}, $responseBody');
    }
  }


  /// Mengupdate data absensi
  static Future<void> updateAbsensi({
  required int id,
  required String status,
  String? keterangan,
  File? foto,
  }) async {
  final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/absensi/$id'));

  request.fields['status'] = status;
  if (keterangan != null) request.fields['keterangan'] = keterangan;
  if (foto != null) {
  request.files.add(await http.MultipartFile.fromPath('foto_absensi', foto.path));
  }

  final response = await request.send();

  if (response.statusCode != 200) {
  final responseBody = await response.stream.bytesToString();
  throw Exception('Gagal update absensi: $responseBody');
  }
  }

  /// Menghapus data absensi berdasarkan ID
  static Future<void> deleteAbsensi(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/absensi/$id'));

  if (response.statusCode != 200) {
  throw Exception('Gagal menghapus absensi');
  }
  }
  static Future<List<Absensi>> fetchAbsensis() async {
    final response = await http.get(Uri.parse('$baseUrl/absensi'));
    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Absensi.fromJson(item)).toList();
  }


  // ==================== DASHBOARD ====================
  static Future<Dashboard> fetchDashboardData() async {
    final data = await fetchOne('dashboard');
    return Dashboard.fromJson(data);
  }

}


class KelolaAbsensiPage extends StatefulWidget {
  const KelolaAbsensiPage({Key? key}) : super(key: key);

  @override
  State<KelolaAbsensiPage> createState() => _KelolaAbsensiPageState();
}

class _KelolaAbsensiPageState extends State<KelolaAbsensiPage> {
  late Future<List<Absensi>> _futureAbsensi;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;
  List<int> _selectedIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAbsensi();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  void _loadAbsensi() {
    setState(() {
      _futureAbsensi = ApiService.fetchAbsensi().then(
            (list) => list.map((e) => Absensi.fromJson(e as Map<String, dynamic>)).toList(),
      ).catchError((error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat absensi: $error'),
              action: SnackBarAction(
                label: 'Coba Lagi',
                onPressed: () => setState(_loadAbsensi),
              ),
            ),
          );
        }
        return <Absensi>[];
      });
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus ${_selectedIds.length} absensi yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                for (var id in _selectedIds) {
                  await ApiService.deleteAbsensi(id);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_selectedIds.length} absensi dihapus')),
                  );
                  setState(() {
                    _selectedIds.clear();
                    _loadAbsensi();
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Absensi'),
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari siswa atau status...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    hint: const Text('Filter Status'),
                    value: _statusFilter,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ...['Hadir', 'Izin', 'Sakit', 'Alfa'].map(
                            (status) => DropdownMenuItem(value: status, child: Text(status)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _statusFilter = value),
                  ),
                ],
              ),
            ),
            if (_selectedIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_selectedIds.length} dipilih'),
                    TextButton(
                      onPressed: _bulkDelete,
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: FutureBuilder<List<Absensi>>(
                future: _futureAbsensi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
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
                  final absensiList = snapshot.data!.where((absensi) {
                    final matchesSearch = absensi.namaSiswa?.toLowerCase().contains(_searchQuery) ?? false ||
                        absensi.status.toLowerCase().contains(_searchQuery);
                    final matchesFilter = _statusFilter == null || absensi.status == _statusFilter;
                    return matchesSearch && matchesFilter;
                  }).toList();
                  if (absensiList.isEmpty) {
                    return const Center(child: Text('Tidak ada data absensi.'));
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
                          leading: Checkbox(
                            value: _selectedIds.contains(absensi.id),
                            onChanged: (_) => _toggleSelection(absensi.id),
                          ),
                          title: Text(
                            absensi.namaSiswa ?? 'Siswa ID: ${absensi.idSiswa}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${absensi.status} - ${Utils.formatTanggal(absensi.tanggal)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.info, color: Utils.mainThemeColor ?? Colors.red),
                            onPressed: () => _showDetailModal(absensi),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor ?? Colors.red,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_absensi');
          if (result == true) setState(_loadAbsensi);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:absensi/models/dashboard.dart';
import 'package:absensi/models/siswa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/absensi.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

Map<String, String> _headers([String? token]) {
  final headers = {'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';
  return headers;
}

Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

Future<Map<String, dynamic>> fetchOne(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final resp = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
  if (resp.statusCode == 200) {
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
  throw Exception('GET $endpoint failed: ${resp.statusCode}');
}

Future<void> sendData(String method, String endpoint, {Map<String, dynamic>? body}) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  final encoded = body == null ? null : jsonEncode(body);
  late http.Response resp;

  switch (method) {
    case 'POST':
      resp = await http.post(url, headers: _headers(), body: encoded).timeout(const Duration(seconds: 10));
      break;
    case 'PUT':
      resp = await http.put(url, headers: _headers(), body: encoded).timeout(const Duration(seconds: 10));
      break;
    case 'DELETE':
      resp = await http.delete(url, headers: _headers()).timeout(const Duration(seconds: 10));
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }

  if (resp.statusCode >= 400) {
    final msg = resp.body.isNotEmpty
        ? (jsonDecode(resp.body) as Map<String, dynamic>)['error'] ?? resp.statusCode
        : resp.statusCode;
    throw Exception('$method $endpoint failed: $msg');
  }
}

// Fungsi utilitas untuk mengambil token
Future<String?> _getToken() async {
  return await const FlutterSecureStorage().read(key: 'token');
}

// Fungsi utilitas untuk mengambil id_siswa dari SharedPreferences
Future<int> _getIdSiswa() async {
  final prefs = await SharedPreferences.getInstance();
  final idSiswa = prefs.getInt('id_siswa');
  if (idSiswa == null || idSiswa == 0) {
    throw Exception('ID Siswa tidak ditemukan atau tidak valid');
  }
  return idSiswa;
}

// Fungsi utilitas untuk mengambil id_kelas dari SharedPreferences
Future<int> _getIdKelas() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id_kelas') ?? 0;
}

// Fungsi utilitas untuk format waktu
 String _formatDateTime(DateTime dt) {
return dt.toLocal().toIso8601String().split('T')[1].split('.')[0]; // HH:mm:ss
}

class ApiService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      // Simpan data ke SharedPreferences
      await prefs.setString('token', body['token']);
      await prefs.setInt('id_users', body['user']['id']);
      await prefs.setString('role', body['user']['role']);
      await prefs.setString('nama', body['user']['nama']);

      // Simpan id_siswa jika ada
      final idSiswa = body['user']['id_siswa'] as int?;
      if (idSiswa != null && idSiswa != 0) {
        await prefs.setInt('id_siswa', idSiswa);
        print('ID Siswa tersimpan: $idSiswa');
      } else {
        await prefs.remove('id_siswa'); // Hapus jika null atau 0
        print('ID Siswa tidak ada atau tidak valid');
      }

      // Simpan id_kelas jika ada
      final idKelas = body['user']['id_kelas'] as int?;
      if (idKelas != null && idKelas != 0) {
        await prefs.setInt('id_kelas', idKelas);
        print('ID Kelas tersimpan: $idKelas');
      } else {
        await prefs.remove('id_kelas'); // Hapus jika null atau 0
        print('ID Kelas tidak ada atau tidak valid');
      }

      return {
        'token': body['token'],
        'user': body['user'],
      };
    } else {
      throw Exception('Login gagal: ${resp.body}');
    }


  }


// Logout (tetap seperti asli)
static Future<void> logout() async {
await const FlutterSecureStorage().deleteAll();
}

// Fetch Current User (tetap seperti asli)
static Future<Map<String, dynamic>> fetchCurrentUser() async {
final token = await _getToken();
final resp = await http.get(Uri.parse('$baseUrl/users/me'), headers: _headers(token));
if (resp.statusCode == 200) {
return json.decode(resp.body) as Map<String, dynamic>;
} else {
throw Exception('Gagal memuat user');
}
}


  static Future<List<Absensi>> getAbsensiHariIni(int idSiswa) async {
    final semua = await getAbsensiByUser(idSiswa);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return semua.where((a) {
      if (a.tanggal == null) return false;
      final tanggalStr = DateFormat('yyyy-MM-dd').format(a.tanggal!.toLocal());
      return tanggalStr == todayStr;
    }).toList();
  }


  /// Ambil semua absensi untuk satu siswa (riwayat lengkap)
  static Future<List<Absensi>> getAbsensiByUser(int idSiswa) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/absensi/siswa/$idSiswa');
    final resp = await http.get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> list = json.decode(resp.body);
      return list.map((e) => Absensi.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat riwayat absensi: ${resp.statusCode}');
  }

  /// Check‑in
  static Future<int> checkIn(int idSiswa) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/absensi');
    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'id_siswa': idSiswa.toString()},
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 201) {
      return (json.decode(resp.body) as Map<String, dynamic>)['id'] as int;
    }
    throw Exception('Check-in gagal: ${resp.statusCode}');
  }

  static Future<http.Response> checkOut(int absensiId) async {
    final url = Uri.parse('$baseUrl/absensi/$absensiId');
    final body = jsonEncode({
      'action': 'check_out',
    });
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response;
  }

  static Future<http.Response> verifyAbsensi(int absensiId) async {
    final url = Uri.parse('$baseUrl/absensi/$absensiId');
    final body = jsonEncode({'action': 'verifikasi'});
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }


  static Future<List<Absensi>> getRiwayatAbsensi(int userId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/absensi?user_id=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Absensi.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat riwayat absensi: ${response.statusCode}');
  }


  static Future<void> deleteAbsensi(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/absensi/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus absensi: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateAbsensiStatus({
    required int id,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/absensi/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal update status absensi');
    }
  }




  /// Ambil semua absensi (untuk admin)
  static Future<List<Absensi>> fetchAbsensi() async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/absensi');
    final resp = await http.get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> list = json.decode(resp.body);
      return list.map((e) => Absensi.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat absensi: ${resp.statusCode}');
  }

// Fungsi lain tetap seperti asli, hanya ditambahkan autentikasi jika diperlukan
static Future<Siswa> getSiswaByUserId(int idUsers) async {
final token = await _getToken();
final response = await http.get(Uri.parse('$baseUrl/siswa/$idUsers'), headers: _headers(token));
if (response.statusCode == 200) {
return Siswa.fromJson(jsonDecode(response.body));
} else {
throw Exception('Gagal mengambil data siswa: ${response.body}');
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

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat data users');
    }
  }

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
  static Future<List<Map<String, dynamic>>> fetchKelas() async {
    final response = await http.get(Uri.parse('$baseUrl/kelas'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat data kelas');
    }
  }

  static Future<Map<String, dynamic>> fetchKelasById(int id) async =>
      fetchOne('kelas/$id');
  static Future<void> createKelas(Map<String, dynamic> data) async =>
      sendData('POST', 'kelas', body: data);
  static Future<void> updateKelas(int id, Map<String, dynamic> data) async =>
      sendData('PUT', 'kelas/$id', body: data);
  static Future<void> deleteKelas(int id) async =>
      sendData('DELETE', 'kelas/$id');

  static Future<Dashboard> fetchDashboardData() async {
    final data = await fetchOne('dashboard');
    return Dashboard.fromJson(data);
  }
}
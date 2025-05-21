// lib/models/siswa.dart
class Siswa {
  final int idSiswa;
  final int idUsers;
  final String nama;
  final String nis;
  final DateTime tanggalLahir;
  final String alamat;
  final String noHp;
  final int idKelas;
  final String namaKelas;
  final String jenisKelamin;

  Siswa({
    required this.idSiswa,
    required this.idUsers,
    required this.nama,
    required this.nis,
    required this.tanggalLahir,
    required this.alamat,
    required this.noHp,
    required this.idKelas,
    required this.namaKelas,
    required this.jenisKelamin,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      idSiswa: json['id_siswa'] as int,
      idUsers: json['id_users'] as int,
      nama: json['nama'] as String,
      nis: json['nis'] as String,
      tanggalLahir: DateTime.parse(json['tanggal_lahir'] as String),
      alamat: json['alamat'] as String,
      noHp: json['no_hp'] as String,
      idKelas: json['id_kelas'] as int,
      namaKelas: json['nama_kelas'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_siswa': idSiswa,
    'id_users': idUsers,
    'nama': nama,
    'nis': nis,
    'tanggal_lahir': tanggalLahir.toIso8601String(),
    'alamat': alamat,
    'no_hp': noHp,
    'id_kelas': idKelas,
    'nama_kelas': namaKelas,
    'jenis_kelamin': jenisKelamin,
  };
}

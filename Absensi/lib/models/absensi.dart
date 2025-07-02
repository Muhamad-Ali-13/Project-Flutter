// models/absensi.dart
class Absensi {
  final int? id;
  final int? id_siswa;
  final int? id_kelas;
  final DateTime? tanggal;
  final String? jam_masuk;
  final String? jam_keluar;
  final String? status;
  final String? keterangan;
  final DateTime? created_at;
  final String? nama_siswa;
  final String? nama_kelas;

  Absensi({
    this.id,
    this.id_siswa,
    this.id_kelas,
    this.tanggal,
    this.jam_masuk,
    this.jam_keluar,
    this.status,
    this.keterangan,
    this.created_at,
    this.nama_siswa,
    this.nama_kelas,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'] as int?,
      id_siswa: json['id_siswa'] as int?,
      id_kelas: json['id_kelas'] as int?,
      tanggal: json['tanggal'] != null ? DateTime.parse(json['tanggal'].toString()) : null,
      jam_masuk: json['jam_masuk'] as String?,
      jam_keluar: json['jam_keluar'] as String?,
      status: json['status'] as String?,
      keterangan: json['keterangan'] as String?,
      created_at: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      nama_siswa: json['nama_siswa'] as String?,
      nama_kelas: json['nama_kelas'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_siswa': id_siswa,
      'id_kelas': id_kelas,
      'tanggal': tanggal?.toIso8601String().split('T')[0],
      'jam_masuk': jam_masuk,
      'jam_keluar': jam_keluar,
      'status': status,
      'keterangan': keterangan,
      'created_at': created_at?.toIso8601String(),
      'nama_siswa': nama_siswa,
      'nama_kelas': nama_kelas,
    };
  }
}
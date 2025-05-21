// lib/models/dashboard.dart
class Dashboard {
  final int totalUser;
  final int totalGuru;
  final int totalKelas;
  final int totalSiswa;
  final int totalMapel;
  final int totalJadwal;
  final int totalAbsensi;

  Dashboard({
    required this.totalUser,
    required this.totalGuru,
    required this.totalKelas,
    required this.totalSiswa,
    required this.totalMapel,
    required this.totalJadwal,
    required this.totalAbsensi,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalUser: (json['totalUser'] as int?) ?? 0,
      totalGuru: (json['totalGuru'] as int?) ?? 0,
      totalKelas: (json['totalKelas'] as int?) ?? 0,
      totalSiswa: (json['totalSiswa'] as int?) ?? 0,
      totalMapel: (json['totalMapel'] as int?) ?? 0,
      totalJadwal: (json['totalJadwal'] as int?) ?? 0,
      totalAbsensi: (json['totalAbsensi'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalUser': totalUser,
    'totalGuru': totalGuru,
    'totalKelas' : totalKelas,
    'totalSiswa': totalSiswa,
    'totalMapel' : totalMapel,
    'totalJadwal' : totalJadwal,
    'totalAbsensi': totalAbsensi,
  };
}

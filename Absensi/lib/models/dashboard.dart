class Dashboard {
  final int totalUser;
  final int totalGuru;
  final int totalKelas;
  final int totalSiswa;
  final int totalAbsensi;
  final List<AbsensiHarian> absensiList;

  Dashboard({
    required this.totalUser,
    required this.totalGuru,
    required this.totalKelas,
    required this.totalSiswa,
    required this.totalAbsensi,
    required this.absensiList,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalUser: json['total_user'] ?? 0,
      totalGuru: json['total_guru'] ?? 0,
      totalKelas: json['total_kelas'] ?? 0,
      totalSiswa: json['total_siswa'] ?? 0,
      totalAbsensi: json['total_absensi'] ?? 0,
      absensiList: (json['absensi_list'] as List<dynamic>? ?? [])
          .map((e) => AbsensiHarian.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AbsensiHarian {
  final String tanggal;
  final int total;
  final String status;

  AbsensiHarian({
    required this.tanggal,
    required this.total,
    required this.status,
  });

  factory AbsensiHarian.fromJson(Map<String, dynamic> json) {
    return AbsensiHarian(
      tanggal: json['tanggal'],
      total: json['total'],
      status: json['status']
    );
  }
}

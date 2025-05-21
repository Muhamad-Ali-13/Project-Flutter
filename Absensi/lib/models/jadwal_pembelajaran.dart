class JadwalPembelajaran {
  final int idJadwal;
  final int idGuru;
  final int idKelas;
  final int idMapel;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaGuru; // From users.nama via guru
  final String namaKelas; // From kelas.nama_kelas
  final String namaMapel; // From mapel.nama_mapel

  JadwalPembelajaran({
    required this.idJadwal,
    required this.idGuru,
    required this.idKelas,
    required this.idMapel,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaGuru,
    required this.namaKelas,
    required this.namaMapel,
  });

  factory JadwalPembelajaran.fromRow(List<dynamic> row) => JadwalPembelajaran(
    idJadwal: row[0] as int,
    idGuru: row[1] as int,
    idKelas: row[2] as int,
    idMapel: row[3] as int,
    hari: row[4] as String,
    jamMulai: row[5].toString(), // Convert TIME to String
    jamSelesai: row[6].toString(), // Convert TIME to String
    namaGuru: row[7] as String? ?? 'Unknown', // From users.nama
    namaKelas: row[8] as String? ?? 'Unknown', // From kelas.nama_kelas
    namaMapel: row[9] as String? ?? 'Unknown', // From mapel.nama_mapel
  );

  factory JadwalPembelajaran.fromJson(Map<String, dynamic> json) =>
      JadwalPembelajaran(
        idJadwal: json['id_jadwal'] as int,
        idGuru: json['id_guru'] as int,
        idKelas: json['id_kelas'] as int,
        idMapel: json['id_mapel'] as int,
        hari: json['hari'] as String,
        jamMulai: json['jam_mulai'] as String,
        jamSelesai: json['jam_selesai'] as String,
        namaGuru: json['nama_guru'] as String? ?? 'Unknown',
        namaKelas: json['nama_kelas'] as String? ?? 'Unknown',
        namaMapel: json['nama_mapel'] as String? ?? 'Unknown',
      );

  Map<String, dynamic> toJson() => {
    'id_jadwal': idJadwal,
    'id_guru': idGuru,
    'id_kelas': idKelas,
    'id_mapel': idMapel,
    'hari': hari,
    'jam_mulai': jamMulai,
    'jam_selesai': jamSelesai,
    'nama_guru': namaGuru,
    'nama_kelas': namaKelas,
    'nama_mapel': namaMapel,
  };
}
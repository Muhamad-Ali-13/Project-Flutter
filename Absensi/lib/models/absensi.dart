class Absensi {
  final int id;
  final int idSiswa;
  final int idKelas;
  final int idGuru;
  final int idMapel;
  final int idJadwal;
  final DateTime tanggal;
  final String? jamMasuk;
  final String? jamKeluar;
  final String status;
  final String? keterangan;
  final String? fotoAbsensi;
  final String? namaSiswa;
  final String? namaKelas;
  final String? namaGuru;
  final String? namaMapel;
  final String? namaJadwal;

  Absensi({
    required this.id,
    required this.idSiswa,
    required this.idKelas,
    required this.idGuru,
    required this.idMapel,
    required this.idJadwal,
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    required this.status,
    this.keterangan,
    this.fotoAbsensi,
    this.namaSiswa,
    this.namaKelas,
    this.namaGuru,
    this.namaMapel,
    this.namaJadwal,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'] as int,
      idSiswa: json['id_siswa'] as int,
      idKelas: json['id_kelas'] as int,
      idGuru: json['id_guru'] as int,
      idMapel: json['id_mapel'] as int,
      idJadwal: json['id_jadwal'] as int,
      tanggal: DateTime.parse(json['tanggal'] as String),
      jamMasuk: json['jam_masuk'] as String?,
      jamKeluar: json['jam_keluar'] as String?,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String?,
      fotoAbsensi: json['foto_absensi'] as String?,
      namaSiswa: json['nama_siswa'] as String?,
      namaKelas: json['nama_kelas'] as String?,
      namaGuru: json['nama_guru'] as String?,
      namaMapel: json['nama_mapel'] as String?,
      namaJadwal: json['nama_jadwal'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_siswa': idSiswa,
    'id_kelas': idKelas,
    'id_guru': idGuru,
    'id_mapel': idMapel,
    'id_jadwal': idJadwal,
    'tanggal': tanggal.toIso8601String().split('T').first,
    'jam_masuk': jamMasuk,
    'jam_keluar': jamKeluar,
    'status': status,
    'keterangan': keterangan,
    'foto_absensi': fotoAbsensi,
  };
}
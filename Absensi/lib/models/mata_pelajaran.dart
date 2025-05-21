class MataPelajaran {
  final int idMapel;
  final String namaMapel;

  MataPelajaran({
    required this.idMapel,
    required this.namaMapel,
  });

  factory MataPelajaran.fromJson(Map<String, dynamic> json) {
    return MataPelajaran(
      idMapel: json['id_mapel'] as int,
      namaMapel: json['nama_mapel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mapel': idMapel,
      'nama_mapel': namaMapel,
    };
  }
}

class Kelas {
  final int idKelas;
  final String namaKelas;
  final int? idGuru;
  final String? namaGuru;

  Kelas({
    required this.idKelas,
    required this.namaKelas,
    this.idGuru,
    this.namaGuru,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      idKelas: json['id_kelas'],
      namaKelas: json['nama_kelas'],
      idGuru: json['id_guru'], // pastikan ini nullable
      namaGuru: json['nama_guru'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
      'id_guru': idGuru,
      // nama_guru biasanya tidak dikirim ke backend karena relasi ditangani oleh backend
    };
  }
}

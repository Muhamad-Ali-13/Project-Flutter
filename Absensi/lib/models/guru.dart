class Guru {
  final int idGuru;
  final int idUsers;
  final String nama; // Added field for user's name
  final String nip;
  final String jenisKelamin;
  final String? noHp;

  Guru({
    required this.idGuru,
    required this.idUsers,
    required this.nama,
    required this.nip,
    required this.jenisKelamin,
    this.noHp,
  });

  factory Guru.fromRow(List<dynamic> row) {
    return Guru(
      idGuru: row[0] as int,
      idUsers: row[1] as int,
      nama: row[2] as String, // Map nama from query result
      nip: row[3] as String,
      jenisKelamin: row[4] as String,
      noHp: row[5] as String?,
    );
  }

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      idGuru: json['id_guru'] as int,
      idUsers: json['id_users'] as int,
      nama: json['users']?['nama'] ?? 'Tanpa Nama',// Include nama in JSON parsing
      nip: json['nip'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      noHp: json['no_hp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_guru': idGuru,
      'id_users': idUsers,
      'nama': nama, // Include nama in JSON response
      'nip': nip,
      'jenis_kelamin': jenisKelamin,
      'no_hp': noHp,
    };
  }
}
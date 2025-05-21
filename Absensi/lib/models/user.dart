class User {
  final int idUsers;
  final String nama;
  final String email;
  final String? password;
  final String? role;

  User({
    required this.idUsers,
    required this.nama,
    required this.email,
    this.password,
    this.role,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsers: json['id_users'] as int,
      nama: (json['nama'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_users': idUsers,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}

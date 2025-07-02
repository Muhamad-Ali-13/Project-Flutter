import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Utils {
  static const Color mainThemeColor = Color(0xFFFF0000);


  /// Fungsi untuk membandingkan apakah dua tanggal memiliki hari, bulan, dan tahun yang sama
  static bool sameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Format tanggal ke string (misalnya: 12 Juni 2025)
  static String formatTanggal(DateTime date) {
    // Bisa disesuaikan ke format lokal lain
    return '${date.day.toString().padLeft(2, '0')} '
        '${_bulanIndonesia(date.month)} '
        '${date.year}';
  }

  static String _bulanIndonesia(int bulan) {
    const bulanList = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan];
  }


  static String formatJam(String? time) {
    if (time == null) return 'N/A';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  static InputDecoration generateInputDecoration({
    required String hintText,
    required IconData iconData,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(iconData),
      border: const OutlineInputBorder(),
      suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
    );
  }

  /// Generate a TextFormField with consistent styling and optional validator.
  static Widget generateInputField({
    required String hintText,
    required IconData iconData,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      obscuringCharacter: '*',
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(iconData),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  // ---------------------------
  // Penambahan untuk login user
  // ---------------------------
  static Map<String, dynamic>? loggedInUser;

  /// Set data user yang sedang login (misal dari response API)
  static void setLoggedInUser(Map<String, dynamic> user) {
    loggedInUser = user;
  }

  /// Ambil id_siswa dari user yang sedang login, null jika tidak ada
  static int? getLoggedInSiswaId() {
    if (loggedInUser != null && loggedInUser!.containsKey('id_siswa')) {
      return loggedInUser!['id_siswa'];
    }
    return null;
  }
}



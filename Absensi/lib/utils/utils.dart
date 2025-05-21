import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Utils {
  static const Color mainThemeColor = Color(0xFFFF0000);

  // Warna gradasi merah dari gelap ke terang
  static LinearGradient get redGradient => LinearGradient(
    colors: [
      Colors.red.shade900,
      Colors.red.shade500,
      Colors.red.shade300,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static String formatTanggal(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
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



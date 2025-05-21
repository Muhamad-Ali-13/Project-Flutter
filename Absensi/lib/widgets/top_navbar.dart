import 'package:absensi/utils/utils.dart';
import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Menghilangkan tombol back
      backgroundColor: Utils.mainThemeColor,
      title: const Text(
        'Absensi Siswa SMAN 1 CIAWI',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
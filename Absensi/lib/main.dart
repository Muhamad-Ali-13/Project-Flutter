// lib/main.dart
import 'package:flutter/material.dart';

// Import Models
import 'models/user.dart';
import 'models/siswa.dart';
import 'models/guru.dart';
import 'models/kelas.dart';
import 'models/mata_pelajaran.dart';
import 'models/jadwal_pembelajaran.dart';
import 'models/absensi.dart';

// Import Pages
import 'pages/splash_page.dart';
import 'pages/login_page.dart';

import 'pages/admin/user/user_add_page.dart';
import 'pages/admin/user/user_edit_page.dart';

import 'pages/admin/siswa/siswa_add_page.dart';
import 'pages/admin/siswa/siswa_edit_page.dart';

import 'pages/admin/guru/guru_add_page.dart';
import 'pages/admin/guru/guru_edit_page.dart';

import 'pages/admin/kelas/kelas_add_page.dart';
import 'pages/admin/kelas/kelas_edit_page.dart';

import 'pages/admin/mapel/mata_pelajaran_add_page.dart';
import 'pages/admin/mapel/mata_pelajaran_edit_page.dart';

import 'pages/admin/jadwal/add_jadwal_pembelajaran_page.dart';
import 'pages/admin/jadwal/edit_jadwal_pembelajaran_page.dart';

import 'pages/admin/absensi/absensi_add_page.dart';
import 'pages/admin/absensi/absensi_edit_page.dart';

import 'widgets/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/login': (context) => const LoginPage(),

        // User routes
        '/add_user': (context) => const AddUserPage(),
        '/edit_user': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return EditUserPage(user: user);
        },

        // Siswa routes
        '/add_siswa': (context) => const AddSiswaPage(),
        '/edit_siswa': (context) {
          final siswa = ModalRoute.of(context)!.settings.arguments as Siswa;
          return EditSiswaPage(siswa: siswa);
        },

        // Guru routes
        '/add_guru': (context) => const GuruAddPage(),
        '/edit_guru': (context) {
          final guru = ModalRoute.of(context)!.settings.arguments as Guru;
          return EditGuruPage(guru: guru);
        },

        // Kelas routes
        '/add_kelas': (context) => const AddKelasPage(),
        '/edit_kelas': (context) {
          final kelas = ModalRoute.of(context)!.settings.arguments as Kelas;
          return EditKelasPage(kelas: kelas);
        },

        // Mata Pelajaran routes
        '/mata_pelajaran_add': (context) => const AddMataPelajaranPage(),
        '/mata_pelajaran_edit': (context) {
          final mata_pelajaran = ModalRoute.of(context)!.settings.arguments as MataPelajaran;
          return EditMataPelajaranPage(mapel: mata_pelajaran);
        },

        // Jadwal Pembelajaran routes
        '/add_jadwal_pembelajaran': (context) => const AddJadwalPembelajaranPage(),
        '/edit_jadwal_pembelajaran': (context) {
          final jadwal_pembelajaran = ModalRoute.of(context)!.settings.arguments as JadwalPembelajaran;
          return EditJadwalPembelajaranPage(jadwal: jadwal_pembelajaran);
        },

        // Absensi routes
        '/add_absensi': (context) => const AddAbsensiPage(),
        '/edit_absensi': (context) {
          final absensi = ModalRoute.of(context)!.settings.arguments as Absensi;
          return EditAbsensiPage(absensi: absensi);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final role = settings.arguments as String? ?? 'user';
          return MaterialPageRoute(
            builder: (_) => MainLayout(role: role),
          );
        }
        return null;
      },
    );
  }
}

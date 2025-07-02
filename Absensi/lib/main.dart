// lib/main.dart
import 'package:absensi/pages/guru/teacher.dart';
import 'package:flutter/material.dart';

// Import Models
import 'models/user.dart';
import 'models/siswa.dart';
import 'models/guru.dart';
import 'models/kelas.dart';
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
        // '/teacher': (context) => const TeacherPage(),

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

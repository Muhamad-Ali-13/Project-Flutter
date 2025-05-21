import 'package:flutter/material.dart';

// Import pages
import '../pages/admin/dashboard_admin_page.dart';
import '../pages/admin/user/user_page.dart';
import '../pages/admin/siswa/siswa_page.dart';
import '../pages/admin/guru/guru_page.dart';
import '../pages/admin/kelas/kelas_page.dart';
import '../pages/admin/mapel/mata_pelajaran_page.dart';
import '../pages/admin/jadwal/jadwal_pembelajaran_page.dart';
import '../pages/admin/absensi/absensi_page.dart';
import '../pages/admin/absensi/kelola_absensi_page.dart';
import '../pages/profile_page.dart';
import 'top_navbar.dart';

class MainLayout extends StatefulWidget {
  final String role;
  const MainLayout({Key? key, required this.role}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _items;

  @override
  void initState() {
    super.initState();
    _setupPagesAndItems(widget.role);
  }

  void _setupPagesAndItems(String role) {
    if (role == 'admin') {
      _pages = [
        const DashboardAdminPage(),
        const MasterMenuPage(),
        const KelolaAbsensiPage(),
        const ProfilPage(),
      ];
      _items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Master'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Absensi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      // Untuk siswa/guru
      _pages = [
        const DashboardUserPage(),
        const AbsensiPage(),
        const ProfilPage(),
      ];
      _items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Absensi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavbar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AnimatedBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNavigationBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 200),
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected ? Colors.white : Colors.grey[300],
                          size: isSelected ? 28 : 24,
                        ),
                        child: items[index].icon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      items[index].label!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: isSelected ? 14 : 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MasterMenuPage extends StatelessWidget {
  const MasterMenuPage({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, Icons.admin_panel_settings, 'User', const UserPage()),
            _buildCard(context, Icons.person, 'Guru', const GuruPage()),
            _buildCard(context, Icons.class_, 'Kelas', const KelasPage()),
            _buildCard(context, Icons.school, 'Siswa', const SiswaPage()),
            _buildCard(context, Icons.book, 'Mapel', const MataPelajaranPage()),
            _buildCard(context, Icons.schedule, 'Jadwal', const JadwalPembelajaranPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () => _navigateTo(context, page),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, Icons.how_to_reg, 'Absensi', '/absensi'),
            _buildCard(context, Icons.schedule, 'Jadwal', '/jadwal'),
            _buildCard(context, Icons.book, 'Mata Pelajaran', '/mapel'),
            _buildCard(context, Icons.person, 'Profil', '/profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
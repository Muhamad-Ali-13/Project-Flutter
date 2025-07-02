import 'package:absensi/pages/guru/teacher.dart';
import 'package:absensi/pages/siswa/absensi_page.dart';
import 'package:flutter/material.dart';

// Import pages
import '../pages/admin/dashboard_admin_page.dart';
import '../pages/admin/absensi/kelola_absensi_page.dart';
import '../pages/profile_page.dart';

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
        const KelolaAbsensiPage(),
        const ProfileScreen(),
      ];
      _items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Kelola Absensi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (role == 'guru') {
      _pages = [
        const TeacherPage(),
        const KelolaAbsensiPage(),
        const ProfileScreen(),
      ];
      _items = const [
        BottomNavigationBarItem(icon: Icon(Icons.verified), label: 'Verify'),
        BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Kelola Absensi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      _pages = [
        const AbsensiPage(),
        const ProfileScreen(),
      ];
      _items = const [
        BottomNavigationBarItem(icon: Icon(Icons.co_present_outlined), label: 'Absensi'),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFFF0000).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: isSelected ? Color(0xFFFF0000) : Colors.grey,
                      size: isSelected ? 28 : 24,
                    ),
                    child: item.icon,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.red : Colors.grey,
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


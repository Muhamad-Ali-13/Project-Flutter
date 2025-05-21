import 'package:flutter/material.dart';

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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
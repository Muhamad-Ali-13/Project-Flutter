import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({Key? key}) : super(key: key);

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  late Future<Dashboard> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _futureDashboard = ApiService.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1000;

    double childAspectRatio = isMobile
        ? 1 / 1.2
        : isTablet
        ? 1 / 1.4
        : 1 / 1.6;

    return Scaffold(
      //



      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Dashboard>(
            future: _futureDashboard,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Terjadi kesalahan pada server'));
              }

              final data = snapshot.data!;

              final items = [
                _DashboardItem('Total User', data.totalUser, Icons.person, Colors.red),
                _DashboardItem('Total Guru', data.totalGuru, Icons.badge, Colors.red),
                _DashboardItem('Total Kelas', data.totalKelas, Icons.class_, Colors.red),
                _DashboardItem('Total Siswa', data.totalSiswa, Icons.school, Colors.red),
                _DashboardItem('Total Mapel', data.totalMapel, Icons.book, Colors.red),
                _DashboardItem('Total Jadwal', data.totalJadwal, Icons.timer, Colors.red),
                _DashboardItem('Absensi', data.totalAbsensi, Icons.event_available, Colors.red),
              ];

              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 200 : 250,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCard(item, isMobile);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_DashboardItem item, bool isMobile) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: isMobile ? 36 : 48, color: item.color),
              const SizedBox(height: 12),
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  _DashboardItem(this.title, this.value, this.icon, this.color);
}

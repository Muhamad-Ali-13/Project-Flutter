import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard.dart';
import '../../services/api_service.dart';
import 'absensi_detail_page.dart';
import '../../pages/admin/user/user_page.dart';
import '../../pages/admin/siswa/siswa_page.dart';
import '../../pages/admin/guru/guru_page.dart';
import '../../pages/admin/kelas/kelas_page.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Absensi Siswa SMAN 1 CIAWI'),
        backgroundColor: const Color.fromARGB(255, 255, 7, 0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
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
              _DashboardItem('User', data.totalUser, Icons.person, const Color.fromARGB(255, 255, 7, 0), page: const UserPage()),
              _DashboardItem('Guru', data.totalGuru, Icons.badge, const Color.fromARGB(255, 255, 7, 0), page: const GuruPage()),
              _DashboardItem('Kelas', data.totalKelas, Icons.class_, const Color.fromARGB(255, 255, 7, 0), page: const KelasPage()),
              _DashboardItem('Siswa', data.totalSiswa, Icons.school, const Color.fromARGB(255, 255, 7, 0),page: const SiswaPage()),
            ];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16, top: 10),
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Absensi Terbaru",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.absensiList.length,
                      itemBuilder: (context, index) {
                        final absensi = data.absensiList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.event_available, color: Colors.green),
                            title: Text(
                              "Tanggal: ${absensi.tanggal}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "Jumlah: ${absensi.total} siswa hadir",
                              style: GoogleFonts.inter(),
                            ),
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => AbsensiDetailPage(absensi: absensi),
                            //     ),
                            //   );
                            // },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(_DashboardItem item, bool isMobile) {
    return InkWell(
      onTap: () {
        if (item.page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.page!),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: isMobile ? 36 : 48, color: item.color),
              const SizedBox(height: 12),
              Text(
                item.value.toString(),
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: GoogleFonts.inter(
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
  final Widget? page;

  _DashboardItem(this.title, this.value, this.icon, this.color, {this.page});
}

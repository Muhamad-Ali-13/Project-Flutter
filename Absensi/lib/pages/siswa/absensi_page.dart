import 'dart:async';
import 'package:absensi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart';
import '../../models/absensi.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({Key? key}) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  String? _checkInTime;
  String? _checkOutTime;
  List<Absensi> _absensiList = [];
  bool _isLoading = true;
  int? _idSiswa;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _loadUserData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id_siswa');
    if (id == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pengguna tidak ditemukan. Silakan login ulang.'),
          ),
        );
      }
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    setState(() => _idSiswa = id);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_idSiswa == null) return;
    setState(() => _isLoading = true);
    try {
      final todayList = await ApiService.getAbsensiHariIni(_idSiswa!);
      final today = todayList.isNotEmpty ? todayList.first : null;

      final historyList = await ApiService.getAbsensiByUser(_idSiswa!);

      setState(() {
        _checkInTime = today?.jam_masuk;
        _checkOutTime = today?.jam_keluar;
        _absensiList = historyList;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> _handleCheckIn() async {
    if (_idSiswa == null || _checkInTime != null) return;
    setState(() => _isLoading = true);
    try {
      final newId = await ApiService.checkIn(_idSiswa!);

      // Tambahkan jam saat ini sebagai check-in yang ditampilkan segera
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm:ss').format(now);
      setState(() {
        _checkInTime = formattedTime;
      });

      await _fetchData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-In berhasil.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-In gagal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    if (_idSiswa == null || _checkOutTime != null) return;

    setState(() => _isLoading = true);

    try {
      // Ambil data today dari _absensiList yang sudah di-fetch sebelumnya
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Absensi? today;
      try {
        today = _absensiList.firstWhere(
              (a) =>
          a.tanggal != null &&
              DateFormat('yyyy-MM-dd').format(a.tanggal!) == todayStr,
        );
      } catch (_) {
        today = null;
      }

      if (today == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum melakukan check-in.')),
          );
        }
        return;
      }

      if (today.jam_masuk == null || today.id == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data check-in tidak valid.')),
          );
        }
        return;
      }

      print('Checking out for absensi ID: ${today.id}');
      final response = await ApiService.checkOut(today.id!);
      if (response.statusCode == 200) {
        await _fetchData(); // Refresh data
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Check-Out berhasil.')),
          );
        }
      } else {
        throw Exception('Gagal check-out: ${response.body}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-Out gagal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    try {
      final dt = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Siswa'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: AnalogClock(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    isLive: true,
                    hourHandColor: Colors.black,
                    minuteHandColor: Colors.black,
                    secondHandColor: Utils.mainThemeColor,
                    showNumbers: true,
                    showTicks: true,
                    datetime: _now,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeCard('Check-In', formatTime(_checkInTime)),
                  _buildTimeCard('Check-Out', formatTime(_checkOutTime)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: !_isLoading && _checkInTime == null ? _handleCheckIn : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Check-In'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: !_isLoading && _checkInTime != null && _checkOutTime == null ? _handleCheckOut : null,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check-Out'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Riwayat Absensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _absensiList.isEmpty
                    ? const Center(child: Text('Belum ada data absensi.'))
                    : ListView.builder(
                  itemCount: _absensiList.length,
                  itemBuilder: (context, i) {
                    final a = _absensiList[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          a.tanggal != null
                              ? DateFormat('dd MMM yyyy').format(a.tanggal!)
                              : 'N/A',
                        ),
                        subtitle: Text(
                          'Masuk: ${formatTime(a.jam_masuk)}  |  Pulang: ${formatTime(a.jam_keluar)}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String label, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        width: 140,
        height: 70,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

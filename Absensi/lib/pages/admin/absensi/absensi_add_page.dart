import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';

class AddAbsensiPage extends StatefulWidget {
  const AddAbsensiPage({super.key});

  @override
  State<AddAbsensiPage> createState() => _AddAbsensiPageState();
}

class _AddAbsensiPageState extends State<AddAbsensiPage> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();

  int? _selectedSiswaId;
  int? _selectedKelasId;
  int? _selectedGuruId;
  int? _selectedMapelId;
  int? _selectedJadwalId;
  DateTime? _selectedTanggal;
  TimeOfDay? _jamMasuk;
  TimeOfDay? _jamKeluar;
  String? _selectedStatus;
  File? _imageFile;
  bool _isSaving = false;
  bool _isLoadingDropdown = true;

  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> siswaList = [];
  List<Map<String, dynamic>> kelasList = [];
  List<Map<String, dynamic>> guruList = [];
  List<Map<String, dynamic>> mapelList = [];
  List<Map<String, dynamic>> jadwalList = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final responses = await Future.wait([
        ApiService.fetchSiswas(),
        ApiService.fetchKelas(),
        ApiService.fetchGurus(),
        ApiService.fetchMataPelajarans(),
        ApiService.fetchJadwalPembelajarans(),
      ]);

      siswaList = responses[0] is List
          ? List<Map<String, dynamic>>.from(responses[0])
          : [];
      kelasList = responses[1] is List
          ? List<Map<String, dynamic>>.from(responses[1])
          : [];
      guruList = responses[2] is List
          ? List<Map<String, dynamic>>.from(responses[2])
          : [];
      mapelList = responses[3] is List
          ? List<Map<String, dynamic>>.from(responses[3])
          : [];
      jadwalList = responses[4] is List
          ? List<Map<String, dynamic>>.from(responses[4])
          : [];
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDropdown = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedTanggal = picked);
  }

  Future<void> _pickJam({required bool masuk}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (masuk) {
          _jamMasuk = picked;
        } else {
          _jamKeluar = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedSiswaId == null ||
        _selectedKelasId == null ||
        _selectedGuruId == null ||
        _selectedMapelId == null ||
        _selectedJadwalId == null ||
        _selectedTanggal == null ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data wajib terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final jamMasukFormatted = _jamMasuk != null
          ? '${_jamMasuk!.hour.toString().padLeft(2, '0')}:${_jamMasuk!.minute.toString().padLeft(2, '0')}:00'
          : null;
      final jamKeluarFormatted = _jamKeluar != null
          ? '${_jamKeluar!.hour.toString().padLeft(2, '0')}:${_jamKeluar!.minute.toString().padLeft(2, '0')}:00'
          : null;

      await ApiService.createAbsensi(
        idSiswa: _selectedSiswaId!,
        idKelas: _selectedKelasId!,
        idGuru: _selectedGuruId!,
        idMapel: _selectedMapelId!,
        idJadwal: _selectedJadwalId!,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedTanggal!),
        jamMasuk: jamMasukFormatted,
        jamKeluar: jamKeluarFormatted,
        status: _selectedStatus!,
        keterangan: _keteranganController.text,
        foto: _imageFile,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Absensi')),
      body: _isLoadingDropdown
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Siswa'),
                value: _selectedSiswaId,
                items: siswaList.map((siswa) {
                  return DropdownMenuItem<int>(
                    value: int.parse(siswa['id_siswa'].toString()),
                    child: Text(siswa['nama_siswa']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSiswaId = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                value: _selectedKelasId,
                items: kelasList.map((kelas) {
                  return DropdownMenuItem<int>(
                    value: int.parse(kelas['id_kelas'].toString()),
                    child: Text(kelas['nama_kelas']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedKelasId = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Guru'),
                value: _selectedGuruId,
                items: guruList.map((guru) {
                  return DropdownMenuItem<int>(
                    value: guru['id_guru'],
                    child: Text(guru['nama_guru']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedGuruId = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Mata Pelajaran'),
                value: _selectedMapelId,
                items: mapelList.map((mapel) {
                  return DropdownMenuItem<int>(
                    value: mapel['id_mapel'],
                    child: Text(mapel['nama_mapel']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMapelId = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Jadwal'),
                value: _selectedJadwalId,
                items: jadwalList.map((jadwal) {
                  return DropdownMenuItem<int>(
                    value: jadwal['id_jadwal'],
                    child: Text(
                        '${jadwal['nama_jadwal']} (${jadwal['jam_mulai']} - ${jadwal['jam_selesai']})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedJadwalId = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
        ListTile(
          title: Text(
            _selectedTanggal != null
                ? DateFormat('yyyy-MM-dd').format(_selectedTanggal!)
                : 'Pilih Tanggal',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickTanggal,
        ),

        ListTile(
          title: Text(
            _jamMasuk != null
                ? _jamMasuk!.format(context)
                : 'Pilih Jam Masuk (opsional)',
          ),
          trailing: const Icon(Icons.login),
          onTap: () => _pickJam(masuk: true),
        ),

        ListTile(
          title: Text(
            _jamKeluar != null
                ? _jamKeluar!.format(context)
                : 'Pilih Jam Keluar (opsional)',
          ),
          trailing: const Icon(Icons.logout),
          onTap: () => _pickJam(masuk: false),
      ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _selectedStatus,
                items: ['Hadir', 'Izin', 'Sakit', 'Alfa'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val),
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan (opsional)'),
              ),
              const SizedBox(height: 12),
              Text('Foto Absensi (opsional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text('Ketuk untuk ambil foto'))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: const Text('Simpan Absensi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

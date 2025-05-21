import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../../widgets/absensi_main_button.dart';
import '../../../models/mata_pelajaran.dart';
import '../../../services/api_service.dart';

class EditMataPelajaranPage extends StatefulWidget {
  final MataPelajaran mapel;
  const EditMataPelajaranPage({Key? key, required this.mapel}) : super(key: key);

  @override
  State<EditMataPelajaranPage> createState() => _EditMataPelajaranPageState();
}

class _EditMataPelajaranPageState extends State<EditMataPelajaranPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaMapelController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaMapelController = TextEditingController(text: widget.mapel.namaMapel);
  }

  @override
  void dispose() {
    _namaMapelController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final mapel = MataPelajaran(
        idMapel: widget.mapel.idMapel,
        namaMapel: _namaMapelController.text.trim(),
      );
      await ApiService.updateMataPelajaran(mapel.idMapel, mapel.toJson());
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update mata pelajaran: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mata Pelajaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Utils.generateInputField(
                hintText: 'Nama Mapel',
                iconData: Icons.book,
                controller: _namaMapelController,
                isPassword: false,
                onChanged: (_) {},
              ),
              const Spacer(),
              _isSaving
                  ? const CircularProgressIndicator()
                  : AbsensiMainButton(label: 'Update', onTap: _update),
            ],
          ),
        ),
      ),
    );
  }
}

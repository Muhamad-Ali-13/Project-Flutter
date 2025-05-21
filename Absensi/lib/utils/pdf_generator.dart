import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/absensi.dart';

class PdfGenerator {
  static Future<Uint8List> generateAbsensiReport({
    required List<Absensi> data,
    required String filterTitle,
    required String namaKelas,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Laporan Absensi - $namaKelas',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Filter: $filterTitle'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Tanggal', 'Nama', 'Status', 'Mapel', 'Guru'],
            data: data.map((a) {
              return [
                dateFormat.format(a.tanggal),
                a.namaSiswa ?? 'Siswa ID: ${a.idSiswa}',
                a.status,
                a.namaMapel ?? '-',
                a.namaGuru ?? '-',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}

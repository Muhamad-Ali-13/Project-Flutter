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
    final now = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Halaman ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          pw.Text('LAPORAN ABSENSI SISWA SMAN 1 CIAWI',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              )),
          pw.SizedBox(height: 4),
          pw.Text('Kelas: $namaKelas',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
                color: PdfColors.black,
              )),
          pw.SizedBox(height: 2),
          pw.Text('Tanggal: $filterTitle',
              style: const pw.TextStyle(fontSize: 12)),
          pw.Text('Tanggal Cetak: $now',
              style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [
              'Nama Siswa',
              'Kelas',
              'Tanggal',
              'Jam Masuk',
              'Jam Keluar',
              'Status',
              'Keterangan'
            ],
            data: data.map((abs) {
              return [
                abs.nama_siswa ?? '-',
                abs.nama_kelas ?? '-',
                abs.tanggal != null ? dateFormat.format(abs.tanggal!) : '-',
                abs.jam_masuk ?? '-',
                abs.jam_keluar ?? '-',
                abs.status ?? '-',
                abs.keterangan ?? '-',
              ];
            }).toList(),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerStyle: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.red500),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.2),
              6: const pw.FlexColumnWidth(2.2),
            },
            border: pw.TableBorder.all(
              color: PdfColors.grey400,
              width: 0.5,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}

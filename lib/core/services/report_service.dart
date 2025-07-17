import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sistem_penjurian_burung/core/models/hasil_akhir_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';

class ReportService {
  Future<void> generateAndShareSesiReport({
    required SesiModel sesi,
    required List<JuaraEntry> hasilJuara,
    required Map<String, UserModel> userMap,
  }) async {
    // 1. Buat file Excel
    var excel = Excel.createExcel();
    Sheet sheet = excel['Hasil Juara'];
    excel.delete('Sheet1');

    // 2. Buat Header
    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString("#1A1A2E"),
      fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // --- PERBAIKAN PENTING DI SINI ---
    // Buat daftar header menggunakan TextCellValue
    final headerRow = [
      TextCellValue('Peringkat'),
      TextCellValue('No. Gantangan'),
      TextCellValue('Nama Pemilik'),
      TextCellValue('Total Skor'),
    ];
    sheet.appendRow(headerRow);

    // Terapkan style ke setiap sel di baris header
    for (int i = 0; i < headerRow.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    // 3. Isi data juara
    for (var juara in hasilJuara) {
      final pemilik = userMap[juara.userId];
      // Buat daftar data untuk setiap baris menggunakan CellValue yang sesuai
      sheet.appendRow([
        IntCellValue(juara.peringkat),
        IntCellValue(juara.nomorGantangan),
        TextCellValue(pemilik?.nama ?? 'N/A'),
        DoubleCellValue(juara.totalSkor),
      ]);
    }

    // Atur lebar kolom otomatis
    for (int i = 0; i < headerRow.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    // 4. Simpan file ke direktori sementara
    final directory = await getTemporaryDirectory();
    final fileName = 'Laporan_${sesi.nama.replaceAll(' ', '_')}.xlsx';
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // 5. Bagikan file menggunakan share_plus
      final xfile = XFile(filePath, name: fileName);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xfile],
        text: 'Berikut adalah laporan hasil untuk sesi ${sesi.nama}.',
      );
    } else {
      throw Exception('Gagal membuat file Excel.');
    }
  }
}

// Provider untuk ReportService
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

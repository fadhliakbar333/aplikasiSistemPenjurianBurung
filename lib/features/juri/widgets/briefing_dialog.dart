import 'package:flutter/material.dart';

class BriefingDialog extends StatelessWidget {
  const BriefingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Peraturan & Cara Menilai'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat bertugas!', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('1. Nilai setiap burung berdasarkan kategori yang telah ditentukan.'),
            SizedBox(height: 4),
            Text('2. Rentang nilai untuk setiap kategori adalah 1 - 100.'),
            SizedBox(height: 4),
            Text('3. Setelah skor disimpan, Anda dapat mengubah lagi skornya apabila ada kesalahan hingga sesi penjurian berakhir dan dikunci oleh admin.'),
            SizedBox(height: 4),
            Text('4. Penilaian akan otomatis ditutup saat waktu sesi berakhir atau dikunci oleh Admin.'),
            SizedBox(height: 16),
            Text('Nilailah secara objektif dan adil. Terima kasih.'),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Tutup dialog dan kembalikan nilai 'true'
            Navigator.of(context).pop(true);
          },
          child: const Text('Saya Paham & Siap Menilai'),
        ),
      ],
    );
  }
}

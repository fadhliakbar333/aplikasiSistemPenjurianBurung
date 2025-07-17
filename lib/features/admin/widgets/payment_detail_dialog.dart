import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class PaymentDetailDialog extends ConsumerWidget {
  final PendaftaranModel pendaftaran;
  const PaymentDetailDialog({super.key, required this.pendaftaran});

  Future<void> _handleAction(BuildContext context, WidgetRef ref, StatusPembayaran newStatus) async {
    try {
      await ref.read(firestoreServiceProvider).updateStatusPembayaran(pendaftaran.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diperbarui!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Verifikasi Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (pendaftaran.buktiPembayaranUrl != null)
              Image.network(
                pendaftaran.buktiPembayaranUrl!,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Text('Gagal memuat gambar.'),
              )
            else
              const Text('Bukti pembayaran tidak ditemukan.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _handleAction(context, ref, StatusPembayaran.ditolak),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Tolak'),
        ),
        ElevatedButton(
          onPressed: () => _handleAction(context, ref, StatusPembayaran.lunas),
          child: const Text('Setujui'),
        ),
      ],
    );
  }
}

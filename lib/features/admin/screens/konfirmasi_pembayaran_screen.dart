import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/widgets/payment_detail_dialog.dart';
import 'package:intl/intl.dart';

class KonfirmasiPembayaranScreen extends ConsumerWidget {
  const KonfirmasiPembayaranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPaymentsAsync = ref.watch(pendingPaymentsProvider);
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pembayaran'),
      ),
      body: pendingPaymentsAsync.when(
        data: (pendaftaranList) {
          if (pendaftaranList.isEmpty) {
            return const Center(child: Text('Tidak ada pembayaran yang menunggu konfirmasi.'));
          }
          return allUsersAsync.when(
            data: (allUsers) {
              final userMap = {for (var user in allUsers) user.uid: user};
              return ListView.builder(
                itemCount: pendaftaranList.length,
                itemBuilder: (context, index) {
                  final pendaftaran = pendaftaranList[index];
                  final peserta = userMap[pendaftaran.userId];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(peserta?.nama ?? 'Nama tidak ditemukan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Event: ${pendaftaran.eventNama}'),
                          Text('Sesi: ${pendaftaran.sesiNama}'),
                          Text('Tanggal Event: ${DateFormat('d MMMM yyyy').format(pendaftaran.eventTanggal)}'),
                          Text('Total Bayar: Rp ${pendaftaran.totalBayar}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PaymentDetailDialog(pendaftaran: pendaftaran),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Gagal memuat data pengguna: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal memuat pembayaran: $e')),
      ),
    );
  }
}

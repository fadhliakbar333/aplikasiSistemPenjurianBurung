import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentHistoryAsync = ref.watch(paymentHistoryProvider);
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
      ),
      body: paymentHistoryAsync.when(
        data: (pendaftaranList) {
          if (pendaftaranList.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pembayaran.'));
          }
          return allUsersAsync.when(
            data: (allUsers) {
              final userMap = {for (var user in allUsers) user.uid: user};
              return ListView.builder(
                itemCount: pendaftaranList.length,
                itemBuilder: (context, index) {
                  final pendaftaran = pendaftaranList[index];
                  final peserta = userMap[pendaftaran.userId];
                  final status = pendaftaran.status;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(peserta?.nama ?? 'Nama tidak ditemukan'),
                      subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Event: ${pendaftaran.eventNama}'),
                          Text('Tanggal Event: ${DateFormat('d MMMM yyyy').format(pendaftaran.eventTanggal)}'),
                          Text('Sesi: ${pendaftaran.sesiNama}'),
                          Text('Total Bayar: Rp ${pendaftaran.totalBayar}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          status.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: status == StatusPembayaran.lunas ? Colors.green : Colors.red,
                      ),
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
        error: (e, s) => Center(child: Text('Gagal memuat riwayat: $e')),
      ),
    );
  }
}

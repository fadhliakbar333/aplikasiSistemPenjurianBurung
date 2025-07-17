import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class DaftarPesertaScreen extends ConsumerWidget {
  final SesiModel sesi;
  const DaftarPesertaScreen({super.key, required this.sesi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendaftaranAsync = ref.watch(pendaftaranProvider(sesi.id));
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Peserta Sesi: ${sesi.nama}'),
      ),
      body: allUsersAsync.when(
        data: (allUsers) {
          // Buat Map untuk pencarian pengguna yang lebih efisien
          final userMap = {for (var user in allUsers) user.uid: user};

          return pendaftaranAsync.when(
            data: (pendaftaranList) {
              if (pendaftaranList.isEmpty) {
                return const Center(child: Text('Belum ada peserta yang mendaftar.'));
              }
              // Tampilkan informasi kuota di atas daftar
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Terisi: ${pendaftaranList.length} / ${sesi.kuota}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pendaftaranList.length,
                      itemBuilder: (context, index) {
                        final pendaftaran = pendaftaranList[index];
                        final peserta = userMap[pendaftaran.userId];
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(pendaftaran.nomorGantangan == 0 ? '?' : pendaftaran.nomorGantangan.toString()),
                            ),
                            title: Text(peserta?.nama ?? 'Nama tidak ditemukan'),
                            subtitle: Text(peserta?.email ?? 'Email tidak ditemukan'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error memuat pendaftaran: $e'),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text('Error memuat pengguna: $e'),
      ),
    );
  }
}

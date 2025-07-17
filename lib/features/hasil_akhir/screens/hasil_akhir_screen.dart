import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class HasilAkhirScreen extends ConsumerWidget {
  final String sesiId;
  final String sesiNama;

  const HasilAkhirScreen({
    super.key,
    required this.sesiId,
    required this.sesiNama,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasilAkhirAsync = ref.watch(hasilAkhirProvider(sesiId));
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Juara Sesi: $sesiNama'),
      ),
      body: hasilAkhirAsync.when(
        data: (hasil) {
          if (hasil == null || hasil.daftarJuara.isEmpty) {
            return const Center(
              child: Text('Hasil akhir untuk sesi ini belum difinalisasi oleh Admin.'),
            );
          }

          return allUsersAsync.when(
            data: (allUsers) {
              final userMap = {for (var user in allUsers) user.uid: user};

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: hasil.daftarJuara.length,
                itemBuilder: (context, index) {
                  final juara = hasil.daftarJuara[index];
                  final pemilik = userMap[juara.userId];

                  IconData peringkatIcon;
                  Color peringkatColor;
                  switch (juara.peringkat) {
                    case 1:
                      peringkatIcon = Icons.military_tech;
                      peringkatColor = Colors.amber;
                      break;
                    case 2:
                      peringkatIcon = Icons.military_tech;
                      peringkatColor = Colors.grey.shade400;
                      break;
                    case 3:
                      peringkatIcon = Icons.military_tech;
                      peringkatColor = Colors.brown.shade400;
                      break;
                    default:
                      peringkatIcon = Icons.star_border;
                      peringkatColor = Colors.grey;
                  }

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(peringkatIcon, color: peringkatColor),
                          Text(
                            '#${juara.peringkat}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      title: Text('No. Gantangan: ${juara.nomorGantangan}'),
                      subtitle: Text('Pemilik: ${pemilik?.nama ?? "N/A"}'),
                      trailing: Text(
                        '${juara.totalSkor.toStringAsFixed(2)} Poin',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error memuat data pengguna: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error memuat hasil akhir: $e')),
      ),
    );
  }
}

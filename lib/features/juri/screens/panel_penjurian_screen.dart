import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/penilaian_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_status.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/juri/widgets/add_skor_dialog.dart';

class PanelPenjurianScreen extends ConsumerWidget {
  final SesiModel sesi;
  const PanelPenjurianScreen({super.key, required this.sesi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendaftaranAsync = ref.watch(pendaftaranProvider(sesi.id));
    final myScoresAsync = ref.watch(myScoresProvider(sesi.id));
    
    final isReadOnly = sesi.status == SesiStatus.selesai;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReadOnly ? 'Hasil Penilaian: ${sesi.nama}' : 'Penjurian: ${sesi.nama}'),
      ),
      body: myScoresAsync.when(
        data: (myScores) {
          return pendaftaranAsync.when(
            data: (pendaftaranList) {
              if (pendaftaranList.isEmpty) {
                return const Center(child: Text('Belum ada peserta yang mendaftar di sesi ini.'));
              }
              
              pendaftaranList.sort((a, b) => a.nomorGantangan.compareTo(b.nomorGantangan));

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemCount: pendaftaranList.length,
                itemBuilder: (context, index) {
                  final pendaftaran = pendaftaranList[index];
                  final nomorGantangan = pendaftaran.nomorGantangan == 0 ? '?' : pendaftaran.nomorGantangan.toString();
                  
                  final myScoreForThisGantangan = myScores.firstWhere((s) => s.pendaftaranId == pendaftaran.id, orElse: () => PenilaianModel.empty());
                  final sudahDinilai = myScoreForThisGantangan.id.isNotEmpty;

                  return Card(
                    color: sudahDinilai ? Colors.green.shade100 : Theme.of(context).cardColor,
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddSkorDialog(
                            pendaftaran: pendaftaran,
                            sesi: sesi,
                            existingPenilaian: sudahDinilai ? myScoreForThisGantangan : null,
                            isReadOnly: isReadOnly,
                          ),
                        );
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(nomorGantangan, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            if (sudahDinilai)
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error Peserta: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error Skor: $err')),
      ),
    );
  }
}

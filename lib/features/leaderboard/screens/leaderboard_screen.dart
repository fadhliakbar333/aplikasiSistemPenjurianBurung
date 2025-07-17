import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart'; // <-- Import SesiModel
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

// Helper class untuk menampung data yang sudah diproses
class LeaderboardEntry {
  final int nomorGantangan;
  final double totalSkor; // <-- Ubah menjadi double untuk skor berkoma

  LeaderboardEntry({required this.nomorGantangan, required this.totalSkor});
}

class LeaderboardScreen extends ConsumerWidget {
  final SesiModel sesi; // <-- Terima seluruh objek sesi

  const LeaderboardScreen({
    super.key,
    required this.sesi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allScoresAsync = ref.watch(leaderboardProvider(sesi.id));
    final pendaftaranAsync = ref.watch(pendaftaranProvider(sesi.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Leaderboard: ${sesi.nama}'),
      ),
      body: allScoresAsync.when(
        data: (allScores) {
          return pendaftaranAsync.when(
            data: (pendaftaranList) {
              if (allScores.isEmpty) {
                return const Center(child: Text('Belum ada skor yang masuk.'));
              }

              // --- LOGIKA PERHITUNGAN SKOR TERTIMBANG ---
              final Map<String, double> skorPerPeserta = {};
              final Map<String, int> bobot = sesi.kategoriBobot;

              for (var penilaian in allScores) {
                double skorTertimbang = 0.0;
                penilaian.skorPerKategori.forEach((kategori, skor) {
                  final bobotKategori = bobot[kategori] ?? 0;
                  skorTertimbang += (skor * bobotKategori) / 100.0;
                });

                skorPerPeserta.update(
                  penilaian.pendaftaranId,
                  (value) => value + skorTertimbang,
                  ifAbsent: () => skorTertimbang,
                );
              }

              final List<LeaderboardEntry> leaderboardEntries = [];
              for (var pendaftaran in pendaftaranList) {
                final totalSkor = skorPerPeserta[pendaftaran.id] ?? 0.0;
                final nomorGantangan = pendaftaran.nomorGantangan == 0 
                    ? pendaftaranList.indexOf(pendaftaran) + 1 
                    : pendaftaran.nomorGantangan;
                
                leaderboardEntries.add(
                  LeaderboardEntry(nomorGantangan: nomorGantangan, totalSkor: totalSkor)
                );
              }

              leaderboardEntries.sort((a, b) => b.totalSkor.compareTo(a.totalSkor));

              return ListView.builder(
                itemCount: leaderboardEntries.length,
                itemBuilder: (context, index) {
                  final entry = leaderboardEntries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('Nomor Gantangan: ${entry.nomorGantangan}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                        // Format skor menjadi 2 angka di belakang koma
                        '${entry.totalSkor.toStringAsFixed(2)} Poin', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error memuat data peserta: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error memuat data skor: $e')),
      ),
    );
  }
}

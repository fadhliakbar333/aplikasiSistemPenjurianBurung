import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:sistem_penjurian_burung/features/hasil_akhir/screens/hasil_akhir_screen.dart';

class PesertaSesiDetailScreen extends ConsumerWidget {
  final SesiModel sesi;
  final PendaftaranModel pendaftaran;

  const PesertaSesiDetailScreen({
    super.key,
    required this.sesi,
    required this.pendaftaran,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau skor untuk pendaftaran spesifik ini
    final myBirdScoresAsync = ref.watch(myBirdScoresProvider(pendaftaran.id));
    // Pantau hasil akhir
    final hasilAkhirAsync = ref.watch(hasilAkhirProvider(sesi.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Sesi: ${sesi.nama}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Kartu Informasi Pendaftaran
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Informasi Pendaftaran Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('No. Gantangan', pendaftaran.nomorGantangan == 0 ? 'Belum Diundi' : pendaftaran.nomorGantangan.toString()),
                      myBirdScoresAsync.when(
                        data: (scores) {
                          double totalSkor = 0;
                          if (scores.isNotEmpty) {
                            // Hitung skor tertimbang
                            final Map<String, int> bobot = sesi.kategoriBobot;
                            for (var penilaian in scores) {
                              double skorTertimbang = 0.0;
                              penilaian.skorPerKategori.forEach((kategori, skor) {
                                final bobotKategori = bobot[kategori] ?? 0;
                                skorTertimbang += (skor * bobotKategori) / 100.0;
                              });
                              totalSkor += skorTertimbang;
                            }
                          }
                          return _buildInfoColumn('Total Skor', totalSkor.toStringAsFixed(2));
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => _buildInfoColumn('Total Skor', 'Error'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Tombol untuk melihat Leaderboard
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.leaderboard),
              label: const Text('Lihat Leaderboard Sesi'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(sesi: sesi),
                ));
              },
            ),
          ),
          // --- TOMBOL BARU UNTUK HASIL AKHIR ---
          hasilAkhirAsync.when(
            data: (hasil) {
              // Hanya tampilkan tombol jika hasil sudah ada
              if (hasil == null) return const SizedBox.shrink();
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Lihat Hasil Juara Resmi'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HasilAkhirScreen(sesiId: sesi.id, sesiNama: sesi.nama),
                    ));
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e,s) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

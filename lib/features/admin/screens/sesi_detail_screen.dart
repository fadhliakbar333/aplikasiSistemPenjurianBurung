import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/core/services/report_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/daftar_peserta_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/edit_sesi_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/lomba_management_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/sesi_management_screen.dart';
import 'package:sistem_penjurian_burung/features/hasil_akhir/screens/hasil_akhir_screen.dart';
import 'package:sistem_penjurian_burung/features/leaderboard/screens/leaderboard_screen.dart';

class SesiDetailScreen extends ConsumerWidget {
  final SesiModel sesi;
  const SesiDetailScreen({super.key, required this.sesi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sesi.nama),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.teal.shade50,
            child: ListTile(
              leading: const Icon(Icons.share, color: Colors.teal),
              title: const Text('Bagikan Laporan Excel'),
              subtitle: const Text('Buat dan bagikan rekapitulasi hasil akhir.'),
              onTap: () async {
                // Logika pengambilan data tetap sama
                final hasilAsync = ref.read(hasilAkhirProvider(sesi.id));
                final allUsersAsync = ref.read(allUsersProvider);

                if (hasilAsync.value == null || allUsersAsync.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data belum siap atau hasil belum difinalisasi.')));
                  return;
                }

                final userMap = {for (var user in allUsersAsync.value!) user.uid: user};

                try {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuat laporan...')));
                  // --- PANGGIL FUNGSI BARU DI SINI ---
                  await ref.read(reportServiceProvider).generateAndShareSesiReport(
                    sesi: sesi,
                    hasilJuara: hasilAsync.value!.daftarJuara,
                    userMap: userMap,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat laporan: $e')));
                } finally {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                }
              },
            ),
          ),
          const Divider(height: 30),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMenuCard(context: context, icon: Icons.gavel, title: 'Kontrol Lomba', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LombaManagementScreen(sesi: sesi)))),
              _buildMenuCard(context: context, icon: Icons.assignment_ind, title: 'Kelola Juri', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SesiManagementScreen(sesi: sesi)))),
              _buildMenuCard(context: context, icon: Icons.leaderboard, title: 'Live Leaderboard', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeaderboardScreen(sesi: sesi)))),
              _buildMenuCard(context: context, icon: Icons.edit, title: 'Edit Sesi', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditSesiScreen(sesi: sesi)))),
              _buildPesertaMenuCard(context, ref, sesi),
              _buildHasilAkhirMenuCard(context, ref, sesi),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPesertaMenuCard(BuildContext context, WidgetRef ref, SesiModel sesi) {
    final pendaftaranAsync = ref.watch(pendaftaranProvider(sesi.id));
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DaftarPesertaScreen(sesi: sesi)));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt, size: 40, color: Colors.blue),
            const SizedBox(height: 12),
            const Text('Peserta Terdaftar', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            pendaftaranAsync.when(
              data: (pendaftaranList) => Text(
                '${pendaftaranList.length} / ${sesi.kuota}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              loading: () => const SizedBox(height: 21, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, s) => const Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilAkhirMenuCard(BuildContext context, WidgetRef ref, SesiModel sesi) {
    final hasilAkhirAsync = ref.watch(hasilAkhirProvider(sesi.id));
    return hasilAkhirAsync.when(
      data: (hasil) {
        final isFinalized = hasil != null;
        return Card(
          elevation: 4,
          color: isFinalized ? Colors.green.shade50 : null,
          child: InkWell(
            onTap: isFinalized
                ? () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HasilAkhirScreen(sesiId: sesi.id, sesiNama: sesi.nama),
                    ));
                  }
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isFinalized ? Icons.emoji_events : Icons.query_stats, size: 40, color: isFinalized ? Colors.green : Colors.grey),
                const SizedBox(height: 12),
                Text('Hasil Resmi', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(isFinalized ? '(Tersedia)' : '(Belum Final)', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(child: Center(child: CircularProgressIndicator())),
      error: (e, s) => const Card(child: Center(child: Icon(Icons.error))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_status.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class LombaManagementScreen extends ConsumerWidget {
  final SesiModel sesi;
  const LombaManagementScreen({super.key, required this.sesi});

  Future<bool> _showConfirmDialog(BuildContext context, {required String title, required String content}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ya, Lanjutkan')),
        ],
      ),
    );
    return confirm ?? false;
  }

  // --- FUNGSI BARU UNTUK FINALISASI ---
  Future<void> _handleFinalisasi(BuildContext context, WidgetRef ref, SesiModel currentSesi) async {
    if (await _showConfirmDialog(context, title: 'Finalisasi Hasil?', content: 'Anda akan menghitung dan menyimpan hasil akhir. Aksi ini akan mempublikasikan daftar juara.')) {
      try {
        // Tampilkan loading indicator
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memproses hasil akhir...')));
        await ref.read(firestoreServiceProvider).finalisasiHasilSesi(currentSesi);
        if (context.mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasil berhasil difinalisasi!')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiState = ref.watch(sesiStreamProvider(sesi.eventId));
    // Pantau juga hasil akhir untuk mengetahui status finalisasi
    final hasilAkhirState = ref.watch(hasilAkhirProvider(sesi.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontrol Lomba: ${sesi.nama}'),
      ),
      body: sesiState.when(
        data: (sesiList) {
          final currentSesi = sesiList.firstWhere((s) => s.id == sesi.id, orElse: () => sesi);
          final isFinalized = hasilAkhirState.value != null;

          // Tentukan kondisi untuk setiap tombol
          final bisaKunciPendaftaran = !currentSesi.isPendaftaranLocked;
          final bisaUndiGantangan = currentSesi.isPendaftaranLocked && !currentSesi.gantanganTelahDiundi;
          final bisaMulaiPenilaian = currentSesi.gantanganTelahDiundi && currentSesi.status == SesiStatus.belumDimulai;
          final bisaSelesaikanPenilaian = currentSesi.status == SesiStatus.berlangsung;
          final bisaFinalisasi = currentSesi.status == SesiStatus.selesai && !isFinalized;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStepCard(
                context: context,
                step: 1,
                title: 'Kunci Pendaftaran',
                subtitle: currentSesi.isPendaftaranLocked ? 'Pendaftaran sudah terkunci.' : 'Mencegah peserta baru mendaftar.',
                isCompleted: currentSesi.isPendaftaranLocked,
                buttonText: 'Kunci',
                onPressed: bisaKunciPendaftaran ? () async {
                  if (await _showConfirmDialog(context, title: 'Kunci Pendaftaran?', content: 'Peserta baru tidak akan bisa mendaftar. Lanjutkan?')) {
                    await ref.read(firestoreServiceProvider).updateSesiStatus(currentSesi.eventId, currentSesi.id, isPendaftaranLocked: true);
                  }
                } : null,
              ),
              _buildStepCard(
                context: context,
                step: 2,
                title: 'Undi Nomor Gantangan',
                subtitle: currentSesi.gantanganTelahDiundi ? 'Nomor gantangan sudah diundi.' : 'Acak nomor untuk semua peserta.',
                isCompleted: currentSesi.gantanganTelahDiundi,
                buttonText: 'Jalankan Undian',
                onPressed: bisaUndiGantangan ? () async {
                  if (await _showConfirmDialog(context, title: 'Jalankan Undian?', content: 'Aksi ini tidak bisa diulang. Lanjutkan?')) {
                    await ref.read(firestoreServiceProvider).undiNomorGantangan(currentSesi.eventId, currentSesi.id);
                  }
                } : null,
              ),
              _buildStepCard(
                context: context,
                step: 3,
                title: 'Mulai Penilaian',
                subtitle: currentSesi.status != SesiStatus.belumDimulai ? 'Penilaian sudah ${currentSesi.status.displayName}.' : 'Izinkan juri untuk mulai menilai.',
                isCompleted: currentSesi.status != SesiStatus.belumDimulai,
                buttonText: 'Mulai',
                buttonColor: Colors.green,
                onPressed: bisaMulaiPenilaian ? () async {
                  if (await _showConfirmDialog(context, title: 'Mulai Penilaian?', content: 'Sesi akan dimulai dan juri bisa mulai menilai.')) {
                    await ref.read(firestoreServiceProvider).updateSesiStatus(currentSesi.eventId, currentSesi.id, status: SesiStatus.berlangsung);
                  }
                } : null,
              ),
              _buildStepCard(
                context: context,
                step: 4,
                title: 'Selesaikan Penilaian',
                subtitle: currentSesi.status == SesiStatus.selesai ? 'Penilaian telah selesai.' : 'Kunci semua skor dari juri.',
                isCompleted: currentSesi.status == SesiStatus.selesai,
                buttonText: 'Selesaikan',
                buttonColor: Colors.orange,
                onPressed: bisaSelesaikanPenilaian ? () async {
                  if (await _showConfirmDialog(context, title: 'Selesaikan Penilaian?', content: 'Sesi akan ditutup dan juri tidak bisa mengubah nilai lagi. Ini adalah aksi final.')) {
                    await ref.read(firestoreServiceProvider).updateSesiStatus(currentSesi.eventId, currentSesi.id, status: SesiStatus.selesai);
                  }
                } : null,
              ),
              _buildStepCard(
                context: context,
                step: 5,
                title: 'Finalisasi Hasil Juara',
                subtitle: isFinalized ? 'Hasil akhir telah dipublikasikan.' : 'Hitung & simpan peringkat juara.',
                isCompleted: isFinalized,
                buttonText: isFinalized ? 'Hasil Telah Final' : 'Finalisasi Hasil',
                buttonColor: Colors.blue,
                onPressed: bisaFinalisasi ? () => _handleFinalisasi(context, ref, currentSesi) : null,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      )
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required int step,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required String buttonText,
    required VoidCallback? onPressed,
    Color? buttonColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                  child: isCompleted 
                      ? const Icon(Icons.check, color: Colors.white) 
                      : Text('$step', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

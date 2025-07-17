import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/event_model.dart';
import 'package:sistem_penjurian_burung/core/models/kategori_penilaian.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/peserta/screens/instruksi_pembayaran_screen.dart';
import 'package:sistem_penjurian_burung/features/peserta/screens/peserta_sesi_detail.dart';

class PesertaEventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const PesertaEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiAsync = ref.watch(sesiStreamProvider(event.id));
    final myRegistrationsAsync = ref.watch(myRegistrationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.nama),
      ),
      body: myRegistrationsAsync.when(
        data: (myRegistrations) {
          return sesiAsync.when(
            data: (sesiList) {
              if (sesiList.isEmpty) {
                return const Center(child: Text('Belum ada sesi untuk event ini.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: sesiList.length,
                itemBuilder: (context, index) {
                  final sesi = sesiList[index];
                  final myRegistrationForThisSesi = myRegistrations.firstWhere(
                    (reg) => reg.sesiId == sesi.id,
                    orElse: () => PendaftaranModel.empty(),
                  );
                  final isRegistered = myRegistrationForThisSesi.id.isNotEmpty;

                  // Memanggil widget kartu yang sudah dirapikan
                  return _SesiCard(
                    sesi: sesi,
                    isRegistered: isRegistered,
                    myRegistration: myRegistrationForThisSesi,
                    event: event,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error Sesi: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error Pendaftaran: $err')),
      ),
    );
  }
}

// --- WIDGET BARU UNTUK KARTU SESI (Lebih Rapi dan Efisien) ---
class _SesiCard extends ConsumerWidget {
  final SesiModel sesi;
  final EventModel event;
  final bool isRegistered;
  final PendaftaranModel myRegistration;

  const _SesiCard({
    required this.sesi,
    required this.isRegistered,
    required this.myRegistration,
    required this.event,
  });

  Future<void> _handleRegistration(BuildContext context, WidgetRef ref, SesiModel sesi, EventModel event) async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus login untuk mendaftar.')));
      return;
    }

    // Tampilkan loading indicator
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      // Panggil fungsi registerForSesi yang sekarang membuat dokumen pendaftaran
      await ref.read(firestoreServiceProvider).registerForSesi(
            eventId: event.id,
            sesiId: sesi.id,
            userId: currentUser.uid,
            hargaTiket: sesi.hargaTiket,
            eventNama: event.nama,
            sesiNama: sesi.nama,
            eventTanggal: event.tanggal,
          );
      
      // Ambil kembali data pendaftaran yang baru dibuat untuk mendapatkan ID dan kode unik
      final myNewestRegistration = await ref.read(myRegistrationsProvider.future);
      final newPendaftaran = myNewestRegistration.firstWhere((p) => p.sesiId == sesi.id);

      if (context.mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pushReplacement( // Ganti halaman saat ini agar tidak bisa kembali
          context,
          MaterialPageRoute(
            builder: (context) => InstruksiPembayaranScreen(
              pendaftaran: newPendaftaran,
              infoPembayaran: event.infoPembayaran,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendaftarSesiAsync = ref.watch(pendaftaranProvider(sesi.id));
    final isLocked = sesi.isPendaftaranLocked;
    final isRegistered = myRegistration.id.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Hanya bisa tap jika sudah lunas
        onTap: isRegistered && myRegistration.status == StatusPembayaran.lunas
            ? () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PesertaSesiDetailScreen(
                    sesi: sesi,
                    pendaftaran: myRegistration,
                  ),
                ));
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColorLight,
              padding: const EdgeInsets.all(12),
              child: Text(sesi.nama, style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sesi.deskripsi.isNotEmpty) ...[
                    Text(sesi.deskripsi),
                    const Divider(height: 24),
                  ],
                  if (sesi.kategoriBobot.isNotEmpty) ...[
                    const Text('Kriteria Penilaian:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: sesi.kategoriBobot.keys.map((kategoriName) {
                          final kategoriEnum = KategoriPenilaian.values.firstWhere((k) => k.name == kategoriName);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(kategoriEnum.displayName),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga Tiket: Rp ${sesi.hargaTiket}'),
                          pendaftarSesiAsync.when(
                            data: (pendaftar) {
                              final pendaftarLunas = pendaftar.where((p) => p.status == StatusPembayaran.lunas).length;
                              final sisaKuota = sesi.kuota - pendaftarLunas;
                              return Text('Sisa Kuota: $sisaKuota', style: TextStyle(color: sisaKuota > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold));
                            },
                            loading: () => const Text('Memuat kuota...'),
                            error: (e, s) => const Text('Error kuota'),
                          ),
                        ],
                      ),
                      // PERBAIKAN UTAMA: Logika yang lebih jelas
                      _buildActionButton(context, ref, pendaftarSesiAsync, isLocked),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, AsyncValue pendaftarSesiAsync, bool isLocked) {
    final isRegistered = myRegistration.id.isNotEmpty;
    
    if (isRegistered) {
      // Jika sudah terdaftar, tampilkan sesuai status
      switch (myRegistration.status) {
        case StatusPembayaran.menungguPembayaran:
          return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InstruksiPembayaranScreen(
                  pendaftaran: myRegistration,
                  infoPembayaran: event.infoPembayaran,
                ),
              ));
            },
            child: const Text('Lanjut Bayar'),
          );
        case StatusPembayaran.menungguKonfirmasi:
          return const Chip(
            label: Text('Menunggu Konfirmasi'),
            backgroundColor: Colors.yellow,
          );
        case StatusPembayaran.lunas:
          return const Chip(
            label: Text('Lunas'),
            backgroundColor: Colors.green,
            avatar: Icon(Icons.check_circle, color: Colors.white),
          );
        case StatusPembayaran.ditolak:
          return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InstruksiPembayaranScreen(
                  pendaftaran: myRegistration,
                  infoPembayaran: event.infoPembayaran,
                ),
              ));
            },
            child: const Text('Bayar Ulang'),
          );
      }
    } else {
      // Jika belum terdaftar, tampilkan tombol daftar
      return pendaftarSesiAsync.when(
        data: (pendaftar) {
          final pendaftarLunas = pendaftar.where((p) => p.status == StatusPembayaran.lunas).length;
          final isFull = (sesi.kuota - pendaftar.length) <= 0;
          return ElevatedButton(
            onPressed: isLocked || isFull ? null : () => _handleRegistration(context, ref, sesi, event),
            style: isLocked || isFull ? ElevatedButton.styleFrom(backgroundColor: Colors.grey) : null,
            child: Text(isLocked ? 'Ditutup' : (isFull ? 'Penuh' : 'Daftar')),
          );
        },
        loading: () => const ElevatedButton(onPressed: null, child: Text('Memuat...')),
        error: (e, s) => const ElevatedButton(onPressed: null, child: Text('Error')),
      );
    }
  }
}

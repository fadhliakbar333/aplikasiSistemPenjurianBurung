import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/event_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/add_sesi_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/sesi_detail_screen.dart'; // <-- Import screen baru

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesiAsync = ref.watch(sesiStreamProvider(event.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(event.nama),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lokasi: ${event.lokasi}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tanggal: ${event.tanggal.day}/${event.tanggal.month}/${event.tanggal.year}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sesi Lomba', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Sesi'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddSesiScreen(event: event),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: sesiAsync.when(
              data: (sesiList) {
                if (sesiList.isEmpty) {
                  return const Center(child: Text('Belum ada sesi untuk event ini.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: sesiList.length,
                  itemBuilder: (context, index) {
                    final sesi = sesiList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(sesi.nama),
                        subtitle: Text('Kuota: ${sesi.kuota}, Harga: Rp ${sesi.hargaTiket}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        // --- PERUBAHAN UTAMA DI SINI ---
                        // Seluruh item list sekarang menjadi tombol navigasi
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SesiDetailScreen(sesi: sesi),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

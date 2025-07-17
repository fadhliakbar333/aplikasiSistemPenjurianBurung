import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/add_event_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/edit_event_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/event_detail_screen.dart';

class EventManagementScreen extends ConsumerWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Event'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Event'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddEventScreen()),
                      );
                    },
                  ),
                ),
              ],              
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('Belum ada event yang dibuat.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(eventStreamProvider),
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(event.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${event.lokasi} - ${event.tanggal.day}/${event.tanggal.month}/${event.tanggal.year}'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditEventScreen(event: event),
                                ));
                              } else if (value == 'delete') {
                                // Logika hapus event
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit Event')),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus Event')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

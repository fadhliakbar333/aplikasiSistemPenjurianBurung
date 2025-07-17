import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/ganti_password_screen.dart';
import 'package:sistem_penjurian_burung/features/peserta/screens/peserta_event_detail.dart';
import 'package:sistem_penjurian_burung/features/theme/widgets/theme_toggle_button.dart';

class PesertaDashboard extends ConsumerWidget {
  const PesertaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Peserta'),
        actions: const [ThemeToggleButton()],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: const Text('Menu Peserta', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Daftar Event'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Ganti Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GantiPasswordScreen(isFromDrawer: true),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // --- LOGIKA LOGOUT YANG DIPERBARUI ---
                ref.invalidate(userDataProvider);
                ref.invalidate(assignedSesiProvider);
                ref.invalidate(myRegistrationsProvider);
                ref.invalidate(myScoresProvider);
                ref.read(authServiceProvider).signOut();
              },
            ),
          ],
        ),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('Saat ini belum ada event yang tersedia.'),
            );
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
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PesertaEventDetailScreen(event: event),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

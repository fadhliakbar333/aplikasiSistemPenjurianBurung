import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_status.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/ganti_password_screen.dart';
import 'package:sistem_penjurian_burung/features/juri/screens/panel_penjurian_screen.dart';
import 'package:sistem_penjurian_burung/features/juri/widgets/briefing_dialog.dart';
import 'package:sistem_penjurian_burung/features/theme/widgets/theme_toggle_button.dart';

class JuriDashboard extends ConsumerWidget {
  const JuriDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedSesiAsync = ref.watch(assignedSesiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Tugas Juri'),
        actions: const [ThemeToggleButton()],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 120, child: DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).primaryColor), child: const Text('Menu Juri', style: TextStyle(color: Colors.white, fontSize: 24)))),
            ListTile(leading: const Icon(Icons.assignment), title: const Text('Jadwal Tugas'), onTap: () => Navigator.pop(context)),
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
      body: assignedSesiAsync.when(
        data: (sesiList) {
          if (sesiList.isEmpty) {
            return const Center(child: Text('Anda belum memiliki jadwal tugas.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(assignedSesiProvider),
            child: ListView.builder(
              itemCount: sesiList.length,
              itemBuilder: (context, index) {
                final sesi = sesiList[index];
                
                Widget actionButton;
                switch (sesi.status) {
                  case SesiStatus.belumDimulai:
                    actionButton = const ElevatedButton(onPressed: null, child: Text('Belum Dimulai'));
                    break;
                  case SesiStatus.berlangsung:
                    actionButton = ElevatedButton(
                      child: const Text('Mulai / Edit Nilai'),
                      onPressed: () async {
                        final ready = await showDialog<bool>(context: context, builder: (_) => const BriefingDialog());
                        if (ready == true && context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PanelPenjurianScreen(sesi: sesi)));
                        }
                      },
                    );
                    break;
                  case SesiStatus.selesai:
                    actionButton = OutlinedButton(
                      child: const Text('Lihat Penilaian'),
                      onPressed: () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => PanelPenjurianScreen(sesi: sesi)));
                      },
                    );
                    break;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(sesi.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sesi.eventNama),
                        Text('${sesi.eventTanggal.day}/${sesi.eventTanggal.month}/${sesi.eventTanggal.year}'),
                        const SizedBox(height: 4),
                        Text('Status: ${sesi.status.displayName}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: actionButton,
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

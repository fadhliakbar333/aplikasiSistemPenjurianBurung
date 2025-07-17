import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/event_management_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/konfirmasi_pembayaran_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/payment_management_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/user_management_screen.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/ganti_password_screen.dart';
import 'package:sistem_penjurian_burung/features/theme/widgets/theme_toggle_button.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
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
                child: const Text('Menu Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Manajemen Event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EventManagementScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manajemen Pengguna'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Manajemen Pembayaran'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PaymentManagementScreen()));
              },
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context: context,
            icon: Icons.event,
            title: 'Manajemen Event',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EventManagementScreen(),
              ));
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.people,
            title: 'Manajemen Pengguna',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const UserManagementScreen(),
              ));
            },
          ),
          _buildMenuCard(context: context, icon: Icons.receipt_long, title: 'Manajemen Pembayaran', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PaymentManagementScreen()))),
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
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

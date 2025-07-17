import 'package:flutter/material.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/konfirmasi_pembayaran_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/payment_history_screen.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pembayaran'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context: context,
            icon: Icons.pending_actions,
            title: 'Konfirmasi Pembayaran',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const KonfirmasiPembayaranScreen(),
              ));
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.history,
            title: 'Riwayat Pembayaran',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PaymentHistoryScreen(),
              ));
            },
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
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

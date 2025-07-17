import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/admin_dashboard.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/ganti_password_screen.dart';
import 'package:sistem_penjurian_burung/features/juri/screens/juri_dashboard.dart';
import 'package:sistem_penjurian_burung/features/peserta/screens/peserta_dashboard.dart';

class HomeWrapper extends ConsumerWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (user) {
        // --- LOGIKA UTAMA DI SINI ---
        // 1. Cek apakah user wajib ganti password
        if (user.wajibGantiPassword) {
          return const GantiPasswordScreen();
        }

        // 2. Jika tidak, arahkan berdasarkan peran
        switch (user.peran) {
          case UserRole.admin:
            return const AdminDashboard();
          case UserRole.juri:
            return const JuriDashboard();
          case UserRole.peserta:
            return const PesertaDashboard();
        }
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat data pengguna: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

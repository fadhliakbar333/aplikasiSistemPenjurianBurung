import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/app/config/app_theme.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/login_screen.dart';
import 'package:sistem_penjurian_burung/features/auth/screens/verify_email_screen.dart';
import 'package:sistem_penjurian_burung/features/home/screens/home_wrapper.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/features/theme/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(child: SistemPenjurianBurung())
  );
}

class SistemPenjurianBurung extends ConsumerWidget {
  const SistemPenjurianBurung({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Sistem Penjurian Burung',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          } 
          
          // --- LOGIKA BARU UNTUK DEMO ---
          // Cek apakah email pengguna adalah email demo
          final bool isDemoUser = user.email?.endsWith('@demo.com') ?? false;

          // Jika email BUKAN demo DAN belum terverifikasi, tampilkan halaman verifikasi
          if (!isDemoUser && !user.emailVerified) {
            return const VerifyEmailScreen();
          } 
          
          // Jika email adalah demo ATAU sudah terverifikasi, lanjutkan ke Home
          else {
            return const HomeWrapper();
          }
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}

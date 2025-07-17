import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/features/home/screens/home_wrapper.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = ref.read(authServiceProvider).currentUser!.emailVerified;

    if (!isEmailVerified) {
      // Izinkan kirim ulang email setelah 15 detik
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => canResendEmail = true);
      });

      // Cek status verifikasi setiap 3 detik
      timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Muat ulang data pengguna dari Firebase
    await ref.read(authServiceProvider).currentUser?.reload();
    
    setState(() {
      isEmailVerified = ref.read(authServiceProvider).currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      setState(() => canResendEmail = false);
      // Atur timer lagi untuk kirim ulang
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => canResendEmail = true);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verifikasi baru telah dikirim.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika sudah terverifikasi, langsung arahkan ke Home
    if (isEmailVerified) {
      return const HomeWrapper();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email Anda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Email verifikasi telah dikirim ke:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ref.read(authServiceProvider).currentUser?.email ?? 'Email tidak ditemukan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Silakan periksa kotak masuk Anda (termasuk folder spam) dan klik link yang kami berikan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Kirim Ulang Email'),
                onPressed: canResendEmail ? sendVerificationEmail : null,
              ),
              TextButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: const Text('Batal / Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

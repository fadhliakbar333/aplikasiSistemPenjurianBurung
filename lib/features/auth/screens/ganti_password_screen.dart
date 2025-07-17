import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/features/auth/controllers/change_password_controller.dart';

class GantiPasswordScreen extends ConsumerStatefulWidget {
  final bool isFromDrawer;
  const GantiPasswordScreen({super.key, this.isFromDrawer = false});

  @override
  ConsumerState<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends ConsumerState<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(changePasswordControllerProvider.notifier).changePassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantau state dari controller
    final state = ref.watch(changePasswordControllerProvider);

    // Listener untuk menangani navigasi atau pesan setelah aksi selesai
    ref.listen<ChangePasswordState>(changePasswordControllerProvider, (previous, next) {
      if (next.isSuccess && widget.isFromDrawer) {
        // Jika sukses dan diakses dari drawer, tampilkan pesan dan kembali
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui!')),
        );
        Navigator.of(context).pop();
      } else if (next.errorMessage != null) {
        // Jika ada error, tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        automaticallyImplyLeading: widget.isFromDrawer,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isFromDrawer)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: Text(
                      'Untuk keamanan, Anda harus mengganti password sementara Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                TextFormField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(labelText: 'Password Lama'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'Password Baru'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                  obscureText: true,
                  validator: (v) {
                    if (v != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Simpan Password Baru'),
                      ),
                const SizedBox(height: 16),
                if (!widget.isFromDrawer)
                  TextButton(
                    onPressed: () => ref.read(authServiceProvider).signOut(),
                    child: const Text('Logout'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

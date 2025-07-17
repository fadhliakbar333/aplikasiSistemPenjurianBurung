import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';
import 'package:sistem_penjurian_burung/features/admin/screens/add_user_screen.dart';
import 'package:sistem_penjurian_burung/features/admin/widgets/edit_user_role_dialog.dart';
import 'package:sistem_penjurian_burung/features/admin/widgets/reauth_dialog.dart'; // <-- Import dialog baru

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI HELPER BARU UNTUK RE-AUTENTIKASI ---
  Future<bool> _promptForReauthentication() async {
    final reauthenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User harus menekan tombol
      builder: (_) => const ReauthDialog(),
    );
    return reauthenticated ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
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
                    icon: const Icon(Icons.person_add),
                    label: const Text('Tambah Juri / Admin'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddUserScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari berdasarkan nama...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: allUsersAsync.when(
              data: (users) {
                final filteredUsers = users.where((user) {
                  final nameMatches = user.nama.toLowerCase().contains(_searchQuery.toLowerCase());
                  return nameMatches;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('Tidak ada pengguna yang cocok.'));
                }
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(user.nama),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(user.peran.name),
                              backgroundColor: user.peran == UserRole.admin 
                                  ? Colors.red.shade100 
                                  : (user.peran == UserRole.juri ? Colors.blue.shade100 : Colors.grey.shade200),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                // --- ALUR KEAMANAN BARU ---
                                final isReauthenticated = await _promptForReauthentication();
                                if (!isReauthenticated || !mounted) return;

                                // Jika berhasil, lanjutkan aksi
                                if (value == 'edit_role') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditUserRoleDialog(user: user),
                                  );
                                } else if (value == 'delete_user') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi Hapus'),
                                      content: Text('Anda yakin ingin menghapus pengguna "${user.nama}"? Ini hanya akan menghapus data dari database, bukan akun loginnya.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
                                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ref.read(firestoreServiceProvider).deleteUserFromFirestore(user.uid);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data pengguna berhasil dihapus.')));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit_role', child: Text('Ubah Peran')),
                                const PopupMenuItem(value: 'delete_user', child: Text('Hapus Pengguna', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
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

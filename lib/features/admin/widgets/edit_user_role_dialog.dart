import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class EditUserRoleDialog extends ConsumerStatefulWidget {
  final UserModel user;
  const EditUserRoleDialog({super.key, required this.user});

  @override
  ConsumerState<EditUserRoleDialog> createState() => _EditUserRoleDialogState();
}

class _EditUserRoleDialogState extends ConsumerState<EditUserRoleDialog> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.peran;
  }

  Future<void> _updateRole() async {
    try {
      await ref.read(firestoreServiceProvider).updateUserRole(widget.user.uid, _selectedRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peran pengguna berhasil diperbarui!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Peran: ${widget.user.nama}'),
      content: DropdownButtonFormField<UserRole>(
        value: _selectedRole,
        items: UserRole.values.map((role) {
          return DropdownMenuItem(value: role, child: Text(role.name));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRole = value;
            });
          }
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(onPressed: _updateRole, child: const Text('Simpan')),
      ],
    );
  }
}

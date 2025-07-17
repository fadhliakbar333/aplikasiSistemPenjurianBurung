import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class SesiManagementScreen extends ConsumerStatefulWidget {
  final SesiModel sesi;
  const SesiManagementScreen({super.key, required this.sesi});

  @override
  ConsumerState<SesiManagementScreen> createState() => _SesiManagementScreenState();
}

class _SesiManagementScreenState extends ConsumerState<SesiManagementScreen> {
  late List<String> _assignedJuriIds;

  @override
  void initState() {
    super.initState();
    // Salin daftar juri awal ke state lokal agar bisa dimodifikasi
    _assignedJuriIds = List<String>.from(widget.sesi.juriIds);
  }

  Future<void> _saveChanges() async {
    try {
      await ref.read(firestoreServiceProvider).updateJuriForSesi(
            eventId: widget.sesi.eventId,
            sesiId: widget.sesi.id,
            juriIds: _assignedJuriIds,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allJuriAsync = ref.watch(juriListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Sesi: ${widget.sesi.nama}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: allJuriAsync.when(
        data: (allJuri) {
          if (allJuri.isEmpty) {
            return const Center(child: Text('Tidak ada pengguna dengan peran Juri.'));
          }
          return ListView.builder(
            itemCount: allJuri.length,
            itemBuilder: (context, index) {
              final juri = allJuri[index];
              final isAssigned = _assignedJuriIds.contains(juri.uid);

              return CheckboxListTile(
                title: Text(juri.nama),
                subtitle: Text(juri.email),
                value: isAssigned,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Tambahkan juri ke daftar jika belum ada
                      if (!isAssigned) {
                        _assignedJuriIds.add(juri.uid);
                      }
                    } else {
                      // Hapus juri dari daftar
                      _assignedJuriIds.remove(juri.uid);
                    }
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

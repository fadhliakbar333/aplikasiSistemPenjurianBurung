import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/event_model.dart';
import 'package:sistem_penjurian_burung/core/models/kategori_penilaian.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class AddSesiScreen extends ConsumerStatefulWidget {
  final EventModel event;
  const AddSesiScreen({super.key, required this.event});

  @override
  ConsumerState<AddSesiScreen> createState() => _AddSesiScreenState();
}

class _AddSesiScreenState extends ConsumerState<AddSesiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;

  // State lokal untuk mengelola kategori dan bobot
  final Map<String, int> _kategoriBobot = {};
  int _totalBobot = 0;

  @override
  void dispose() {
    _namaController.dispose();
    _kuotaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _calculateTotalBobot() {
    setState(() {
      _totalBobot = _kategoriBobot.values.fold(0, (sum, item) => sum + item);
    });
  }

  void _addKategori() {
    if (_totalBobot >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total bobot sudah mencapai 100.')),
      );
      return;
    }

    KategoriPenilaian? selectedKategori;
    final bobotController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<KategoriPenilaian>(
                hint: const Text('Pilih Kategori'),
                items: KategoriPenilaian.values
                    .where((k) => !_kategoriBobot.containsKey(k.name))
                    .map((KategoriPenilaian kategori) {
                  return DropdownMenuItem<KategoriPenilaian>(
                    value: kategori,
                    child: Text(kategori.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedKategori = value;
                },
              ),
              TextField(
                controller: bobotController,
                decoration: const InputDecoration(labelText: 'Bobot (%)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final bobot = int.tryParse(bobotController.text) ?? 0;
                if (selectedKategori != null && bobot > 0) {
                  if (_totalBobot + bobot > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Total bobot akan melebihi 100.')),
                    );
                    return;
                  }
                  setState(() {
                    _kategoriBobot[selectedKategori!.name] = bobot;
                    _calculateTotalBobot();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSesi() async {
    if (_formKey.currentState!.validate()) {
      if (_totalBobot != 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total bobot dari semua kategori harus 100.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final sesi = SesiModel(
        id: '',
        eventId: widget.event.id,
        nama: _namaController.text,
        kuota: int.parse(_kuotaController.text),
        hargaTiket: int.parse(_hargaController.text),
        deskripsi: _deskripsiController.text,
        kategoriBobot: _kategoriBobot,
        juriIds: [],
        eventNama: widget.event.nama,
        eventLokasi: widget.event.lokasi,
        eventTanggal: widget.event.tanggal,
      );

      try {
        await ref.read(firestoreServiceProvider).createSesi(sesi);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi baru berhasil ditambahkan!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sesi Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Sesi'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kuotaController,
              decoration: const InputDecoration(labelText: 'Kuota Gantangan'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(labelText: 'Harga Tiket (Rp)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Sesi',
                hintText: 'Contoh: Juara 1: Rp 1.000.000 + Trofi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kategori Penilaian (Total: $_totalBobot%)', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addKategori,
                  tooltip: 'Tambah Kategori',
                ),
              ],
            ),
            if (_kategoriBobot.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('Belum ada kategori yang ditambahkan.')),
              ),
            ..._kategoriBobot.entries.map((entry) {
              final kategori = KategoriPenilaian.values.firstWhere((k) => k.name == entry.key);
              return ListTile(
                title: Text(kategori.displayName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${entry.value}%'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _kategoriBobot.remove(entry.key);
                          _calculateTotalBobot();
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveSesi,
                    child: const Text('Simpan Sesi'),
                  ),
          ],
        ),
      ),
    );
  }
}

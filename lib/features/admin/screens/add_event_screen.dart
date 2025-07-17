import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/event_model.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _infoPembayaranController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _infoPembayaranController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih tanggal event')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final newEvent = EventModel(
        id: '', // ID akan dibuat otomatis oleh Firestore
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        tanggal: _selectedDate!,
        infoPembayaran: _infoPembayaranController.text,
      );

      try {
        await ref.read(firestoreServiceProvider).createEvent(newEvent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event berhasil dibuat!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
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
        title: const Text('Buat Event Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Event'),
              validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lokasiController,
              decoration: const InputDecoration(labelText: 'Lokasi Event'),
              validator: (v) => v!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            // --- FORM BARU UNTUK INFO PEMBAYARAN ---
            TextFormField(
              controller: _infoPembayaranController,
              decoration: const InputDecoration(
                labelText: 'Informasi Pembayaran',
                hintText: 'Contoh: BCA 123456 a/n Panitia Lomba',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Informasi pembayaran wajib diisi' : null,
            ),const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih Tanggal Event'
                        : 'Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveEvent,
                    child: const Text('Simpan Event'),
                  ),
          ],
        ),
      ),
    );
  }
}

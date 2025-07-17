import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/kategori_penilaian.dart';
import 'package:sistem_penjurian_burung/core/models/penilaian_model.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

class AddSkorDialog extends ConsumerStatefulWidget {
  final PendaftaranModel pendaftaran;
  final SesiModel sesi;
  final PenilaianModel? existingPenilaian;
  final bool isReadOnly;

  const AddSkorDialog({
    super.key, 
    required this.pendaftaran,
    required this.sesi,
    this.existingPenilaian,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<AddSkorDialog> createState() => _AddSkorDialogState();
}

class _AddSkorDialogState extends ConsumerState<AddSkorDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.sesi.kategoriBobot.keys.forEach((kategoriName) {
      final existingSkor = widget.existingPenilaian?.skorPerKategori[kategoriName];
      _controllers[kategoriName] = TextEditingController(
        text: existingSkor != null ? existingSkor.toString() : '',
      );
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveSkor() async {
    if (_formKey.currentState!.validate()) {
      final juriId = ref.read(authServiceProvider).currentUser?.uid;
      if (juriId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Juri tidak terautentikasi')));
        return;
      }

      setState(() => _isLoading = true);

      final Map<String, int> skorPerKategori = {};
      _controllers.forEach((kategoriName, controller) {
        skorPerKategori[kategoriName] = int.tryParse(controller.text) ?? 0;
      });

      final penilaian = PenilaianModel(
        id: widget.existingPenilaian?.id ?? '',
        sesiId: widget.pendaftaran.sesiId,
        pendaftaranId: widget.pendaftaran.id,
        juriId: juriId,
        skorPerKategori: skorPerKategori,
      );

      try {
        await ref.read(firestoreServiceProvider).submitOrUpdateSkor(penilaian);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomorGantangan = widget.pendaftaran.nomorGantangan == 0 ? 'N/A' : widget.pendaftaran.nomorGantangan;
    return AlertDialog(
      title: Text(widget.isReadOnly ? 'Detail Nilai Gantangan $nomorGantangan' : 'Beri/Ubah Nilai Gantangan $nomorGantangan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.sesi.kategoriBobot.entries.map((entry) {
              final kategoriName = entry.key;
              final bobot = entry.value;
              final kategoriEnum = KategoriPenilaian.values.firstWhere((k) => k.name == kategoriName);
              
              return _buildSkorField(
                _controllers[kategoriName]!,
                '${kategoriEnum.displayName} (Bobot: $bobot%)',
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(widget.isReadOnly ? 'Tutup' : 'Batal')),
        if (!widget.isReadOnly)
          ElevatedButton(
            onPressed: _isLoading ? null : _saveSkor,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
          ),
      ],
    );
  }

  Widget _buildSkorField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: widget.isReadOnly,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (widget.isReadOnly) return null;
          if (value == null || value.isEmpty) {
            return 'Wajib diisi';
          }
          final skor = int.tryParse(value);
          if (skor == null || skor < 1 || skor > 100) {
            return 'Nilai harus antara 1-100';
          }
          return null;
        },
      ),
    );
  }
}

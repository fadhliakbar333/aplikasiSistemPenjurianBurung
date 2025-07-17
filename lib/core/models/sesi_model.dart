import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_status.dart';

class SesiModel {
  final String id;
  final String eventId;
  final String nama;
  final int kuota;
  final int hargaTiket;
  final List<String> juriIds;
  final Map<String, int> kategoriBobot;
  final String deskripsi;
  final bool isPendaftaranLocked;
  final SesiStatus status;
  final bool gantanganTelahDiundi;
  final String eventNama;
  final String eventLokasi;
  final DateTime eventTanggal;

  SesiModel({
    required this.id,
    required this.eventId,
    required this.nama,
    required this.kuota,
    required this.hargaTiket,
    this.juriIds = const [],
    required this.kategoriBobot,
    this.deskripsi = '',
    this.isPendaftaranLocked = false,
    this.gantanganTelahDiundi = false,
    this.status = SesiStatus.belumDimulai,
    required this.eventNama,
    required this.eventLokasi,
    required this.eventTanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'nama': nama,
      'kuota': kuota,
      'hargaTiket': hargaTiket,
      'juriIds': juriIds,
      'kategoriBobot': kategoriBobot,
      'deskripsi': deskripsi,
      'isPendaftaranLocked': isPendaftaranLocked,
      'gantanganTelahDiundi': gantanganTelahDiundi,
      'status': status.toString(),
      'eventNama': eventNama,
      'eventLokasi': eventLokasi,
      'eventTanggal': Timestamp.fromDate(eventTanggal),
    };
  }

  factory SesiModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SesiModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      nama: data['nama'] ?? '',
      kuota: data['kuota'] ?? 0,
      hargaTiket: data['hargaTiket'] ?? 0,
      juriIds: List<String>.from(data['juriIds'] ?? []),
      kategoriBobot: Map<String, int>.from(data['kategoriBobot'] ?? {}),
      deskripsi: data['deskripsi'] ?? '',
      isPendaftaranLocked: data['isPendaftaranLocked'] ?? false,
      status: SesiStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => SesiStatus.belumDimulai,
      ),
      gantanganTelahDiundi: data['gantanganTelahDiundi'] ?? false,
      eventNama: data['eventNama'] ?? 'Nama Event Tidak Ada',
      eventLokasi: data['eventLokasi'] ?? 'Lokasi Tidak Ada',
      eventTanggal: (data['eventTanggal'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum untuk status pembayaran yang jelas
enum StatusPembayaran {
  menungguPembayaran,
  menungguKonfirmasi,
  lunas,
  ditolak,
}

class PendaftaranModel {
  final String id;
  final String eventId;
  final String sesiId;
  final String userId;
  final Timestamp tanggalDaftar;
  int nomorGantangan;
  final String eventNama;
  final String sesiNama;
  final DateTime eventTanggal;

  // --- FIELD BARU UNTUK PEMBAYARAN ---
  final StatusPembayaran status;
  final String? buktiPembayaranUrl;
  final int hargaTiket;
  final int kodeUnik;
  final int totalBayar;

  PendaftaranModel({
    required this.id,
    required this.eventId,
    required this.sesiId,
    required this.userId,
    required this.tanggalDaftar,
    this.nomorGantangan = 0,
    required this.eventNama,
    required this.sesiNama,
    required this.eventTanggal,
    this.status = StatusPembayaran.menungguPembayaran,
    this.buktiPembayaranUrl,
    required this.hargaTiket,
    required this.kodeUnik,
  }) : totalBayar = hargaTiket + kodeUnik;

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'sesiId': sesiId,
      'userId': userId,
      'tanggalDaftar': tanggalDaftar,
      'nomorGantangan': nomorGantangan,
      'eventNama': eventNama,
      'sesiNama': sesiNama,
      'eventTanggal': Timestamp.fromDate(eventTanggal),
      'status': status.name, // Simpan enum sebagai string
      'buktiPembayaranUrl': buktiPembayaranUrl,
      'hargaTiket': hargaTiket,
      'kodeUnik': kodeUnik,
      'totalBayar': totalBayar,
    };
  }

  factory PendaftaranModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PendaftaranModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      sesiId: data['sesiId'] ?? '',
      userId: data['userId'] ?? '',
      tanggalDaftar: data['tanggalDaftar'] ?? Timestamp.now(),
      nomorGantangan: data['nomorGantangan'] ?? 0,
      eventNama: data['eventNama'] ?? 'N/A',
      sesiNama: data['sesiNama'] ?? 'N/A',
      eventTanggal: (data['eventTanggal'] as Timestamp? ?? data['tanggalDaftar']).toDate(),
      status: StatusPembayaran.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StatusPembayaran.menungguPembayaran,
      ),
      buktiPembayaranUrl: data['buktiPembayaranUrl'],
      hargaTiket: data['hargaTiket'] ?? 0,
      kodeUnik: data['kodeUnik'] ?? 0,
    );
  }

  PendaftaranModel.empty()
      : id = '',
        eventId = '',
        sesiId = '',
        userId = '',
        tanggalDaftar = Timestamp.now(),
        nomorGantangan = 0,
        eventNama = '',
        sesiNama = '',
        eventTanggal = DateTime.now(), 
        status = StatusPembayaran.menungguPembayaran,
        buktiPembayaranUrl = null,
        hargaTiket = 0,
        kodeUnik = 0,
        totalBayar = 0;
}

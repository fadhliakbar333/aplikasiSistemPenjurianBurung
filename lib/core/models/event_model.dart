import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String nama;
  final String lokasi;
  final DateTime tanggal;
  final String infoPembayaran;

  EventModel({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.tanggal,
    this.infoPembayaran = '',
  });

  // Mengubah objek EventModel menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      // Simpan tanggal sebagai Timestamp Firestore
      'tanggal': Timestamp.fromDate(tanggal),
      'infoPembayaran': infoPembayaran,
    };
  }

  // Membuat objek EventModel dari dokumen Firestore
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      lokasi: data['lokasi'] ?? '',
      // Baca Timestamp dari Firestore dan ubah menjadi DateTime
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      infoPembayaran: data['infoPembayaran'] ?? '',
    );
  }
}

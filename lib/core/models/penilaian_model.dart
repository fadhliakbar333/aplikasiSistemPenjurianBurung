import 'package:cloud_firestore/cloud_firestore.dart';

class PenilaianModel {
  final String id;
  final String sesiId;
  final String pendaftaranId;
  final String juriId;
  final Map<String, int> skorPerKategori;
  final int totalSkor;

    PenilaianModel.empty() :
    id = '',
    sesiId = '',
    pendaftaranId = '',
    juriId = '',
    skorPerKategori = {},
    totalSkor = 0;

  PenilaianModel({
    required this.id,
    required this.sesiId,
    required this.pendaftaranId,
    required this.juriId,
    required this.skorPerKategori,
  }) : totalSkor = skorPerKategori.values.fold(0, (sum, item) => sum + item);

  Map<String, dynamic> toMap() {
    return {
      'sesiId': sesiId,
      'pendaftaranId': pendaftaranId,
      'juriId': juriId,
      'skorPerKategori': skorPerKategori,
      'totalSkor': totalSkor,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory PenilaianModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PenilaianModel(
      id: doc.id,
      sesiId: data['sesiId'] ?? '',
      pendaftaranId: data['pendaftaranId'] ?? '',
      juriId: data['juriId'] ?? '',
      skorPerKategori: Map<String, int>.from(data['skorPerKategori'] ?? {}),
    );
  }
  // Constructor kosong untuk kasus di mana skor belum ada

}

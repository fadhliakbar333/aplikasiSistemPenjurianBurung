import 'package:cloud_firestore/cloud_firestore.dart';

// Helper class untuk menyimpan satu entri juara
class JuaraEntry {
  final int peringkat;
  final int nomorGantangan;
  final String userId; // Untuk referensi ke pemilik
  final double totalSkor;

  JuaraEntry({
    required this.peringkat,
    required this.nomorGantangan,
    required this.userId,
    required this.totalSkor,
  });

  // Untuk menyimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'peringkat': peringkat,
      'nomorGantangan': nomorGantangan,
      'userId': userId,
      'totalSkor': totalSkor,
    };
  }

  // Untuk membaca dari Firestore
  factory JuaraEntry.fromMap(Map<String, dynamic> map) {
    return JuaraEntry(
      peringkat: map['peringkat'] ?? 0,
      nomorGantangan: map['nomorGantangan'] ?? 0,
      userId: map['userId'] ?? '',
      totalSkor: (map['totalSkor'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Model utama untuk dokumen hasil akhir
class HasilAkhirModel {
  final String id; // Akan sama dengan sesiId
  final List<JuaraEntry> daftarJuara;
  final Timestamp tanggalFinalisasi;

  HasilAkhirModel({
    required this.id,
    required this.daftarJuara,
    required this.tanggalFinalisasi,
  });

  Map<String, dynamic> toMap() {
    return {
      'daftarJuara': daftarJuara.map((juara) => juara.toMap()).toList(),
      'tanggalFinalisasi': tanggalFinalisasi,
    };
  }

  factory HasilAkhirModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HasilAkhirModel(
      id: doc.id,
      daftarJuara: (data['daftarJuara'] as List<dynamic>? ?? [])
          .map((item) => JuaraEntry.fromMap(item as Map<String, dynamic>))
          .toList(),
      tanggalFinalisasi: data['tanggalFinalisasi'] ?? Timestamp.now(),
    );
  }
}

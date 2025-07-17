import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/event_model.dart';
import 'package:sistem_penjurian_burung/core/models/pendaftaran_model.dart';
import 'package:sistem_penjurian_burung/core/models/penilaian_model.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_model.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/models/sesi_status.dart';
import 'package:sistem_penjurian_burung/core/models/hasil_akhir_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // ... (semua method lain dari getUserData hingga getPendaftaranForSesi tetap sama)

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw Exception('User data not found in Firestore.');
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createSesi(SesiModel sesi) async {
    try {
      await _firestore
          .collection('events')
          .doc(sesi.eventId)
          .collection('sesi')
          .add(sesi.toMap());
    } catch (e) {
      throw Exception('Failed to create sesi: $e');
    }
  }

   Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).update(event.toMap());
    } catch (e) {
      throw Exception('Gagal mengupdate event: $e');
    }
  }

  // --- METHOD DELETE BARU ---
  // Catatan: Menghapus dokumen tidak otomatis menghapus sub-koleksinya.
  // Untuk aplikasi produksi, ini idealnya ditangani oleh Cloud Function.
  // Untuk saat ini, kita hanya akan menghapus dokumen utamanya.
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus event: $e');
    }
  }

  Future<void> updateSesi(SesiModel sesi) async {
    try {
      await _firestore
          .collection('events')
          .doc(sesi.eventId)
          .collection('sesi')
          .doc(sesi.id)
          .update(sesi.toMap());
    } catch (e) {
      throw Exception('Gagal mengupdate sesi: $e');
    }
  }

  Future<void> deleteSesi(String eventId, String sesiId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('sesi')
          .doc(sesiId)
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus sesi: $e');
    }
  }

  Stream<List<SesiModel>> getSesiForEvent(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('sesi')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SesiModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> registerForSesi({
    required String eventId,
    required String sesiId,
    required String userId,
    required int hargaTiket,
    required String eventNama,
    required String sesiNama,
    required DateTime eventTanggal,
  }) async {
    try {
      // Buat kode unik 3 digit (100-999)
      final kodeUnik = Random().nextInt(900) + 100;

      final pendaftaran = PendaftaranModel(
        id: '',
        eventId: eventId,
        sesiId: sesiId,
        userId: userId,
        tanggalDaftar: Timestamp.now(),
        hargaTiket: hargaTiket, 
        kodeUnik: kodeUnik, 
        eventNama: eventNama,
        sesiNama: sesiNama,
        eventTanggal: eventTanggal,
      );
      await _firestore.collection('pendaftaran').add(pendaftaran.toMap());
    } catch (e) {
      throw Exception('Gagal mendaftar: $e');
    }
  }

  // --- METHOD BARU UNTUK UPLOAD BUKTI & KONFIRMASI ---
  Future<void> uploadBuktiPembayaran(String pendaftaranId, String downloadUrl) async {
    try {
      await _firestore.collection('pendaftaran').doc(pendaftaranId).update({
        'buktiPembayaranUrl': downloadUrl,
        'status': StatusPembayaran.menungguKonfirmasi.name,
      });
    } catch (e) {
      throw Exception('Gagal mengunggah bukti: $e');
    }
  }

  Future<void> konfirmasiPembayaran(String pendaftaranId) async {
    try {
      await _firestore.collection('pendaftaran').doc(pendaftaranId).update({
        'status': StatusPembayaran.lunas.name,
      });
    } catch (e) {
      throw Exception('Gagal mengkonfirmasi pembayaran: $e');
    }
  }

  Future<void> updateStatusPembayaran(String pendaftaranId, StatusPembayaran status) async {
    try {
      await _firestore.collection('pendaftaran').doc(pendaftaranId).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Gagal memperbarui status pembayaran: $e');
    }
  }

  // --- METHOD BARU UNTUK MENGAMBIL PENDAFTARAN PENDING ---
  Stream<List<PendaftaranModel>> getPendingPayments() {
    return _firestore
        .collection('pendaftaran')
        .where('status', isEqualTo: StatusPembayaran.menungguKonfirmasi.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendaftaranModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<UserModel>> getAllJuri() {
    return _firestore
        .collection('users')
        .where('peran', isEqualTo: 'juri')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

    Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }
  
    // --- METHOD BARU UNTUK MANAJEMEN PENGGUNA ---

  // Mengubah peran seorang pengguna
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'peran': newRole.name});
    } catch (e) {
      throw Exception('Gagal mengubah peran pengguna: $e');
    }
  }

  // Menghapus data pengguna dari Firestore
  // Catatan: Ini tidak menghapus akun dari Firebase Authentication.
  // Untuk aplikasi produksi, ini idealnya ditangani oleh Cloud Function.
  Future<void> deleteUserFromFirestore(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menghapus data pengguna: $e');
    }
  }

  Future<void> updateJuriForSesi({
    required String eventId,
    required String sesiId,
    required List<String> juriIds,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('sesi')
          .doc(sesiId)
          .update({'juriIds': juriIds});
    } catch (e) {
      throw Exception('Failed to update juri: $e');
    }
  }

  Stream<List<SesiModel>> getAssignedSesi(String juriId) {
    debugPrint("[FirestoreService] Mencari sesi untuk Juri UID: $juriId (Query Sederhana)");

    return _firestore
        .collectionGroup('sesi')
        .where('juriIds', arrayContains: juriId)
        .orderBy('eventTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint("[FirestoreService] Query berhasil, ditemukan ${snapshot.docs.length} sesi.");
      return snapshot.docs.map((doc) => SesiModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<PendaftaranModel>> getPendaftaranForSesi(String sesiId) {
    return _firestore
        .collection('pendaftaran')
        .where('sesiId', isEqualTo: sesiId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendaftaranModel.fromFirestore(doc))
            .toList());
  }

    // --- METHOD BARU UNTUK MENDAPATKAN RIWAYAT PENILAIAN JURI ---
  Stream<List<PenilaianModel>> getMyScoresForSesi(String sesiId, String juriId) {
    return _firestore
        .collection('penilaian')
        .where('sesiId', isEqualTo: sesiId)
        .where('juriId', isEqualTo: juriId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PenilaianModel.fromFirestore(doc)) // Anda perlu membuat factory constructor ini
            .toList());
  }
    // --- METHOD BARU UNTUK VALIDASI PENDAFTARAN ---
  Stream<List<PendaftaranModel>> getMyRegistrations(String userId) {
    return _firestore
        .collection('pendaftaran')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendaftaranModel.fromFirestore(doc))
            .toList());
  }

    // --- METHOD BARU UNTUK LEADERBOARD ---
  Stream<List<PenilaianModel>> getAllScoresForSesi(String sesiId) {
    return _firestore
        .collection('penilaian')
        .where('sesiId', isEqualTo: sesiId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PenilaianModel.fromFirestore(doc))
            .toList());
  }
    // --- METHOD BARU UNTUK MENGUNDI NOMOR GANTANGAN ---
  Future<void> undiNomorGantangan(String eventId, String sesiId) async {
    try {
      // 1. Ambil semua pendaftaran untuk sesi ini
      final pendaftaranSnapshot = await _firestore
          .collection('pendaftaran')
          .where('sesiId', isEqualTo: sesiId)
          .get();

      final pendaftaranDocs = pendaftaranSnapshot.docs;
      
      if (pendaftaranDocs.isEmpty) {
        throw Exception('Tidak ada peserta untuk diundi.');
      }
      
      // 2. Buat daftar nomor dari 1 sampai JUMLAH PESERTA
      final int jumlahPeserta = pendaftaranDocs.length;
      final List<int> nomorGantanganTersedia = List.generate(jumlahPeserta, (i) => i + 1);
      
      // 3. Acak daftar nomor tersebut
      nomorGantanganTersedia.shuffle();
      
      // 4. Gunakan WriteBatch untuk efisiensi
      final batch = _firestore.batch();
      
      for (int i = 0; i < pendaftaranDocs.length; i++) {
        final docRef = pendaftaranDocs[i].reference;
        final nomorTerundi = nomorGantanganTersedia[i];
        batch.update(docRef, {'nomorGantangan': nomorTerundi});
      }
      final sesiRef = _firestore.collection('events').doc(eventId).collection('sesi').doc(sesiId);
      batch.update(sesiRef, {'gantanganTelahDiundi': true});      
      // 5. Commit semua perubahan sekaligus
      await batch.commit();

    } catch (e) {
      throw Exception('Gagal melakukan pengundian: $e');
    }
  }
    // --- METHOD BARU UNTUK MENGUNCI SESI ---
  Future<void> updateSesiStatus(String eventId, String sesiId, {
    bool? isPendaftaranLocked,
    SesiStatus? status,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = {};
      if (isPendaftaranLocked != null) {
        dataToUpdate['isPendaftaranLocked'] = isPendaftaranLocked;
      }
      if (status != null) {
        dataToUpdate['status'] = status.toString();
      }

      if (dataToUpdate.isNotEmpty) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('sesi')
            .doc(sesiId)
            .update(dataToUpdate);
      }
    } catch (e) {
      throw Exception('Gagal memperbarui status sesi: $e');
    }
  }

  Future<void> submitOrUpdateSkor(PenilaianModel penilaian) async {
    try {
      final query = await _firestore
          .collection('penilaian')
          .where('sesiId', isEqualTo: penilaian.sesiId)
          .where('pendaftaranId', isEqualTo: penilaian.pendaftaranId)
          .where('juriId', isEqualTo: penilaian.juriId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore.collection('penilaian').doc(docId).update(penilaian.toMap());
      } else {
        await _firestore.collection('penilaian').add(penilaian.toMap());
      }
    } catch (e) {
      throw Exception('Gagal menyimpan skor: $e');
    }
  }
  // --- METHOD BARU UNTUK SKOR PESERTA ---
  Stream<List<PenilaianModel>> getMyBirdScores(String pendaftaranId) {
  return _firestore
      .collection('penilaian')
      .where('pendaftaranId', isEqualTo: pendaftaranId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PenilaianModel.fromFirestore(doc))
          .toList());
  }

    Future<void> finalisasiHasilSesi(SesiModel sesi) async {
    try {
      // 1. Ambil semua pendaftaran dan penilaian untuk sesi ini
      final pendaftaranSnapshot = await _firestore.collection('pendaftaran').where('sesiId', isEqualTo: sesi.id).get();
      final penilaianSnapshot = await _firestore.collection('penilaian').where('sesiId', isEqualTo: sesi.id).get();

      if (penilaianSnapshot.docs.isEmpty) {
        throw Exception('Tidak ada data penilaian untuk difinalisasi.');
      }

      final pendaftaranList = pendaftaranSnapshot.docs.map((doc) => PendaftaranModel.fromFirestore(doc)).toList();
      final allScores = penilaianSnapshot.docs.map((doc) => PenilaianModel.fromFirestore(doc)).toList();

      // 2. Lakukan perhitungan skor tertimbang (sama seperti di leaderboard)
      final Map<String, double> skorPerPeserta = {};
      final Map<String, int> bobot = sesi.kategoriBobot;
      for (var penilaian in allScores) {
        double skorTertimbang = 0.0;
        penilaian.skorPerKategori.forEach((kategori, skor) {
          final bobotKategori = bobot[kategori] ?? 0;
          skorTertimbang += (skor * bobotKategori) / 100.0;
        });
        skorPerPeserta.update(
          penilaian.pendaftaranId,
          (value) => value + skorTertimbang,
          ifAbsent: () => skorTertimbang,
        );
      }

      // 3. Buat daftar entri juara
      final List<JuaraEntry> daftarJuara = [];
      for (var pendaftaran in pendaftaranList) {
        final totalSkor = skorPerPeserta[pendaftaran.id] ?? 0.0;
        daftarJuara.add(JuaraEntry(
          peringkat: 0, // Peringkat akan diisi setelah diurutkan
          nomorGantangan: pendaftaran.nomorGantangan,
          userId: pendaftaran.userId,
          totalSkor: totalSkor,
        ));
      }

      // 4. Urutkan berdasarkan skor tertinggi
      daftarJuara.sort((a, b) => b.totalSkor.compareTo(a.totalSkor));

      // 5. Tetapkan peringkat
      final List<JuaraEntry> hasilFinal = [];
      for (int i = 0; i < daftarJuara.length; i++) {
        hasilFinal.add(JuaraEntry(
          peringkat: i + 1,
          nomorGantangan: daftarJuara[i].nomorGantangan,
          userId: daftarJuara[i].userId,
          totalSkor: daftarJuara[i].totalSkor,
        ));
      }

      // 6. Buat objek HasilAkhirModel dan simpan ke koleksi baru
      final hasilAkhir = HasilAkhirModel(
        id: sesi.id,
        daftarJuara: hasilFinal,
        tanggalFinalisasi: Timestamp.now(),
      );

      await _firestore.collection('hasil_akhir').doc(sesi.id).set(hasilAkhir.toMap());

    } catch (e) {
      throw Exception('Gagal melakukan finalisasi: $e');
    }
  }

  // --- METHOD BARU UNTUK MENGAMBIL HASIL AKHIR ---
  Stream<HasilAkhirModel?> getHasilAkhir(String sesiId) {
    return _firestore
        .collection('hasil_akhir')
        .doc(sesiId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return HasilAkhirModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Stream<List<PendaftaranModel>> getPaymentHistory() {
    return _firestore
        .collection('pendaftaran')
        .where('status', whereIn: [StatusPembayaran.lunas.name, StatusPembayaran.ditolak.name])
        .orderBy('tanggalDaftar', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendaftaranModel.fromFirestore(doc))
            .toList());
  }
  
}

// ---- Riverpod Providers ----
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

// --- PROVIDER YANG SUDAH DIPERBAIKI ---
// Semua provider yang bergantung pada UID pengguna sekarang memantau 'authStateChangesProvider'.
// Ini memastikan mereka akan otomatis di-reset saat pengguna login atau logout.

final userDataProvider = FutureProvider<UserModel>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getUserData(user.uid);
  }
  throw Exception('User not logged in.');
});

final assignedSesiProvider = StreamProvider<List<SesiModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getAssignedSesi(user.uid);
  }
  return Stream.value([]);
});

final myRegistrationsProvider = StreamProvider<List<PendaftaranModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getMyRegistrations(user.uid);
  }
  return Stream.value([]);
});

final myScoresProvider =
    StreamProvider.family<List<PenilaianModel>, String>((ref, sesiId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getMyScoresForSesi(sesiId, user.uid);
  }
  return Stream.value([]);
});

final myBirdScoresProvider =
    StreamProvider.family<List<PenilaianModel>, String>((ref, pendaftaranId) {
  return ref.watch(firestoreServiceProvider).getMyBirdScores(pendaftaranId);
});


// --- PROVIDER GLOBAL ---
final eventStreamProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getEvents();
});

final sesiStreamProvider =
    StreamProvider.family<List<SesiModel>, String>((ref, eventId) {
  return ref.watch(firestoreServiceProvider).getSesiForEvent(eventId);
});

final juriListProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllJuri();
});

final pendaftaranProvider =
    StreamProvider.family<List<PendaftaranModel>, String>((ref, sesiId) {
  return ref.watch(firestoreServiceProvider).getPendaftaranForSesi(sesiId);
});

final leaderboardProvider =
    StreamProvider.family<List<PenilaianModel>, String>((ref, sesiId) {
  return ref.watch(firestoreServiceProvider).getAllScoresForSesi(sesiId);
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllUsers();
});

final hasilAkhirProvider = StreamProvider.family<HasilAkhirModel?, String>((ref, sesiId) {
  return ref.watch(firestoreServiceProvider).getHasilAkhir(sesiId);
});

final pendingPaymentsProvider = StreamProvider<List<PendaftaranModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getPendingPayments();
});

final paymentHistoryProvider = StreamProvider<List<PendaftaranModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getPaymentHistory();
});
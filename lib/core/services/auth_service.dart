import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- Import baru
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/models/user_model.dart';
import  'package:sistem_penjurian_burung/firebase_options.dart'; // <-- Import baru

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService(this._firebaseAuth, this._firestore);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  // Fungsi ini sekarang khusus untuk pendaftaran publik (Peserta)
  Future<void> signUpAsPeserta({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          email: email,
          nama: nama,
          peran: UserRole.peserta,
        );
        await _firestore.collection('users').doc(credential.user!.uid).set(newUser.toMap());
        await sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // --- FUNGSI BARU DAN AMAN UNTUK ADMIN ---
  // Membuat user tanpa mengubah sesi login Admin
  Future<void> createUserAsAdmin({
    required String nama,
    required String email,
    required String password,
    required UserRole peran,
  }) async {
    // Buat instance Firebase sementara
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempAdminSDK', // Nama unik untuk instance sementara
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      // Buat user menggunakan instance sementara
      final UserCredential credential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);
      
      final user = credential.user;
      if (user != null) {
        // Simpan data ke Firestore menggunakan koneksi utama
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          nama: nama,
          peran: peran,
          wajibGantiPassword: true,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        // Kirim email verifikasi ke user baru
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      // Terjemahkan error code agar lebih mudah dibaca
      if (e.code == 'email-already-in-use') {
        throw Exception('Email ini sudah terdaftar.');
      }
      throw Exception('Gagal membuat pengguna: ${e.message}');
    } finally {
      // Selalu hapus instance sementara setelah selesai
      await tempApp.delete();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Pengguna tidak ditemukan.');

      // 1. Re-autentikasi dengan password lama
      await reauthenticateWithPassword(oldPassword);
      
      // 2. Jika berhasil, update password baru
      await user.updatePassword(newPassword);
      
      // 3. Update flag di Firestore menjadi false
      await _firestore.collection('users').doc(user.uid).update({
        'wajibGantiPassword': false,
      });

    } catch (e) {
      // Teruskan error agar bisa ditampilkan di UI
      rethrow;
    }
  }

  // ... (sisa method lain seperti signIn, signOut, reauthenticate, sendEmailVerification tetap sama)
  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Teruskan error spesifik dari Firebase agar bisa ditangani di UI
      throw e;
    }
  }
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Pengguna tidak ditemukan atau email tidak ada.');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Password yang Anda masukkan salah.');
      }
      throw Exception('Gagal melakukan otentikasi ulang.');
    }
  }
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Gagal mengirim email verifikasi: $e');
    }
  }
    Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Jangan beritahu jika user tidak ada untuk alasan keamanan
        // Cukup anggap berhasil agar tidak bisa digunakan untuk menebak email terdaftar
        return;
      }
      throw Exception('Gagal mengirim email reset password: ${e.message}');
    }
  }
}

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final authServiceProvider = Provider<AuthService>((ref) => AuthService(
      ref.watch(firebaseAuthProvider),
      ref.watch(firebaseFirestoreProvider),
    ));
final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(authServiceProvider).authStateChanges);

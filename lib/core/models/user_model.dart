import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, juri, peserta }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin: return 'admin';
      case UserRole.juri: return 'juri';
      case UserRole.peserta: return 'peserta';
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String nama;
  final UserRole peran;
  // --- FIELD BARU ---
  final bool wajibGantiPassword;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.peran,
    this.wajibGantiPassword = false, // Default false untuk pendaftar biasa
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'peran': peran.name,
      'wajibGantiPassword': wajibGantiPassword,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      nama: data['nama'],
      peran: UserRole.values.firstWhere(
        (e) => e.name == data['peran'],
        orElse: () => UserRole.peserta,
      ),
      wajibGantiPassword: data['wajibGantiPassword'] ?? false,
    );
  }
}

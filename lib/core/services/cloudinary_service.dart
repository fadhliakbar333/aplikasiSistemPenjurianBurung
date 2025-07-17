import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudinaryService {
  // --- GANTI DENGAN DATA ANDA DARI LANGKAH 1 ---
  final String _cloudName = "dvo7vmuuo";
  final String _uploadPreset = "bukti_pembayaran";
  // ---------------------------------------------

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  // Mengunggah file bukti pembayaran dan mengembalikan URL yang aman
  Future<String> uploadBuktiPembayaran(File file, String pendaftaranId) async {
    try {
      // Solusi 1: Gunakan timestamp untuk membuat publicId unik
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = '${pendaftaranId}_$timestamp';

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          // Buat folder di Cloudinary untuk setiap pendaftaran
          folder: 'bukti_pembayaran',
          // Beri nama file yang unik dengan timestamp
          publicId: uniquePublicId,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Gagal mengunggah file ke Cloudinary: $e');
    }
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
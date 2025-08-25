import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  // Mengunggah file bukti pembayaran dan mengembalikan URL
  Future<String> uploadBuktiPembayaran(File file, String pendaftaranId) async {
    try {
      //timestamp untuk membuat publicId unik
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = '${pendaftaranId}_$timestamp';

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          // Buat folder di Cloudinary untuk setiap pendaftaran
          folder: dotenv.env['CLOUDINARY_UPLOAD_PRESET'],
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
// Enum untuk semua kemungkinan kategori penilaian
enum KategoriPenilaian {
  iramaLagu,
  volume,
  variasiSuara,
  durasiKerja,
  gayaTarung,
  posturFisik,
  warnaBulu,
  kestabilan,
  responTerhadapLawan,
  kesesuaianGaya
}

// Helper extension untuk mendapatkan nama yang bisa dibaca manusia
extension KategoriPenilaianExtension on KategoriPenilaian {
  String get displayName {
    switch (this) {
      case KategoriPenilaian.iramaLagu:
        return 'Irama Lagu';
      case KategoriPenilaian.volume:
        return 'Volume';
      case KategoriPenilaian.variasiSuara:
        return 'Variasi Suara';
      case KategoriPenilaian.durasiKerja:
        return 'Durasi Kerja';
      case KategoriPenilaian.gayaTarung:
        return 'Gaya Tarung';
      case KategoriPenilaian.posturFisik:
        return 'Postur Fisik';
      case KategoriPenilaian.warnaBulu:
        return 'Warna Bulu';
      case KategoriPenilaian.kestabilan:
        return 'Kestabilan';
      case KategoriPenilaian.responTerhadapLawan:
        return 'Respon Terhadap Lawan';
      case KategoriPenilaian.kesesuaianGaya:
        return 'Kesesuaian Gaya';
      default:
        return '';
    }
  }
}

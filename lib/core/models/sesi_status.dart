enum SesiStatus {
  belumDimulai,
  berlangsung,
  selesai,
}

extension SesiStatusExtension on SesiStatus {
  String get displayName {
    switch (this) {
      case SesiStatus.belumDimulai:
        return 'Belum Dimulai';
      case SesiStatus.berlangsung:
        return 'Berlangsung';
      case SesiStatus.selesai:
        return 'Selesai';
    }
  }
}

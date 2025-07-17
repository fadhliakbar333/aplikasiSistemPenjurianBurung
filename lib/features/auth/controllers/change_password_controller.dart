import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/core/services/auth_service.dart';
import 'package:sistem_penjurian_burung/core/services/firestore_service.dart';

// 1. Definisikan State
// Ini akan menampung semua state yang berhubungan dengan proses ganti password
class ChangePasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// 2. Buat StateNotifier (Controller)
class ChangePasswordController extends StateNotifier<ChangePasswordState> {
  final Ref _ref;
  ChangePasswordController(this._ref) : super(ChangePasswordState());

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(authServiceProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
          );
      // Jika berhasil, set state isSuccess menjadi true
      state = state.copyWith(isLoading: false, isSuccess: true);
      // Invalidate userDataProvider untuk memicu rebuild di HomeWrapper
      _ref.invalidate(userDataProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. Buat Provider
final changePasswordControllerProvider =
    StateNotifierProvider<ChangePasswordController, ChangePasswordState>((ref) {
  return ChangePasswordController(ref);
});

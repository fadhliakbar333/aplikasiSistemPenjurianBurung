import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Definisikan State Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Atur tema awal ke 'light'
  ThemeNotifier() : super(ThemeMode.light);

  // Method untuk mengganti tema
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// 2. Definisikan Provider
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
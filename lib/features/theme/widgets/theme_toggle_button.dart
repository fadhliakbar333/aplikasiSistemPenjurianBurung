import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_penjurian_burung/features/theme/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau tema saat ini
    final currentTheme = ref.watch(themeNotifierProvider);

    return IconButton(
      icon: Icon(
        currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
      ),
      onPressed: () {
        // Panggil method toggle dari provider
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.lexendTextTheme();
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.05,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.15,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: color, height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(color: color, height: 1.45),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

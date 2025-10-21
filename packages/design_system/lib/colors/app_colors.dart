import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color dividerColor = Color.fromARGB(158, 97, 97, 97);

  // Provide 'black' as alias to primaryDark so screens using pure black
  // adopt the design-system dark tone.
  static const Color black = primaryDark;
  static const Color white = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryDark = Color(0xFF0891B2);

  // Surface / Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Greys
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF0F172A);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF3B82F6);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Priority
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityUrgent = Color(0xFF7C2D12);

  // Misc
  static const Color inputColor = Color.fromARGB(255, 59, 59, 59);
  // Background color for inputs when selected/focused
  static const Color inputSelected = Color(0xFF4B4B4B);
  static const Color borderColor = Color.fromRGBO(122, 122, 122, 0.502);
  static const Color borderSelected = Color.fromRGBO(203, 203, 203, 0.502);
}
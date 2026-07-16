import 'package:flutter/material.dart';

/// Instagram / X inspired neutrals — almost no chroma.
abstract final class AppColors {
  // Surfaces
  static const black = Color(0xFF000000);
  static const ink = Color(0xFF0A0A0A);
  static const inkElevated = Color(0xFF121212);
  static const inkCard = Color(0xFF181818);
  static const inkSoft = Color(0xFF1C1C1C);

  static const white = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFFAFAFA);
  static const paper = Color(0xFFFFFFFF);
  static const wash = Color(0xFFF2F2F2);

  // Text
  static const textPrimaryLight = Color(0xFF0F0F0F);
  static const textSecondaryLight = Color(0xFF737373);
  static const textTertiaryLight = Color(0xFFA3A3A3);

  static const textPrimaryDark = Color(0xFFF5F5F5);
  // Slightly brighter greys so body/secondary stay readable on #0A0A0A.
  static const textSecondaryDark = Color(0xFFC4C4C4);
  static const textTertiaryDark = Color(0xFF9A9A9A);

  // Interactive — near-black / near-white, X blue only for rare links
  static const accent = Color(0xFF0F0F0F);
  static const accentOnDark = Color(0xFFF5F5F5);
  static const link = Color(0xFF1D9BF0);

  // Hairlines
  static const borderLight = Color(0x1A000000);
  static const borderDark = Color(0x1AFFFFFF);
  static const dividerLight = Color(0x12000000);
  static const dividerDark = Color(0x14FFFFFF);

  // Glass nav
  static const glassLight = Color(0xE6FAFAFA);
  static const glassDark = Color(0xE6121212);
  static const glassBorderLight = Color(0x14000000);
  static const glassBorderDark = Color(0x1AFFFFFF);

  // Text-only cards: barely-there greys, not pastel candy
  static const cardTints = <Color>[
    Color(0xFFF4F4F4),
    Color(0xFFF7F7F7),
    Color(0xFFF1F1F1),
    Color(0xFFEFEFEF),
    Color(0xFFF5F5F5),
    Color(0xFFF3F3F3),
  ];

  static const cardTintsDark = <Color>[
    Color(0xFF161616),
    Color(0xFF1A1A1A),
    Color(0xFF141414),
    Color(0xFF181818),
    Color(0xFF151515),
    Color(0xFF171717),
  ];

  // Stable monogram plate colors (desaturated)
  static const avatarPlates = <Color>[
    Color(0xFF262626),
    Color(0xFF404040),
    Color(0xFF525252),
    Color(0xFF1F1F1F),
    Color(0xFF333333),
    Color(0xFF2A2A2A),
    Color(0xFF3A3A3A),
    Color(0xFF292929),
  ];
}

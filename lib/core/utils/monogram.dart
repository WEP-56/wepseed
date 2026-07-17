import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

String monogram(String name) {
  final t = name.trim();
  if (t.isEmpty) return '·';
  final first = String.fromCharCode(t.runes.first);
  // Keep CJK as-is; latin uppercased.
  return first.toUpperCase();
}

Color avatarPlate(String seed) {
  final plates = AppColors.avatarPlates;
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return plates[h % plates.length];
}

class MonogramAvatar extends StatelessWidget {
  const MonogramAvatar({
    super.key,
    required this.label,
    this.size = 36,
    this.seed,
    this.filled = true,
  });

  final String label;
  final double size;
  final String? seed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plate = avatarPlate(seed ?? label);
    final bg = filled ? plate : (isDark ? AppColors.inkCard : AppColors.wash);
    final fg = filled
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: filled
            ? null
            : Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
      ),
      child: Text(
        monogram(label),
        style: TextStyle(
          color: fg,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          height: 1,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

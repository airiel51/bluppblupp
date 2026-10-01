import 'package:flutter/material.dart';

/// Official Blupp Logo & Fish Icon Widget
class BluppLogo extends StatelessWidget {
  /// Overall height/size of the logo
  final double size;

  /// Whether to display just the fish icon or fish + 'blupp' text
  final bool iconOnly;

  /// Optional tint color. If null, automatically uses white for dark backgrounds
  /// or dark navy for light backgrounds.
  final Color? color;

  /// Force white or dark version if not tinting
  final bool isDark;

  const BluppLogo({
    super.key,
    this.size = 36,
    this.iconOnly = false,
    this.color,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = iconOnly
        ? (isDark
            ? 'assets/images/blupp_fish_white.png'
            : 'assets/images/blupp_fish_dark.png')
        : (isDark
            ? 'assets/images/blupp_logo_white.png'
            : 'assets/images/blupp_logo_dark.png');

    return Image.asset(
      assetPath,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
    );
  }
}

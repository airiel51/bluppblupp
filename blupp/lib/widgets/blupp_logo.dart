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
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/blupp_logo.jpg',
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, st) {
            return _buildVectorFallback();
          },
        );
      },
    );
  }

  Widget _buildVectorFallback() {
    final tint = color ?? (isDark ? Colors.white : const Color(0xFF1E293B));
    if (iconOnly) {
      return Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        child: Icon(
          Icons.waves_rounded,
          size: size * 0.85,
          color: tint,
        ),
      );
    }
    return SizedBox(
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waves_rounded,
            size: size * 0.55,
            color: tint,
          ),
          const SizedBox(height: 2),
          Text(
            'blupp',
            style: TextStyle(
              color: tint,
              fontSize: size * 0.26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

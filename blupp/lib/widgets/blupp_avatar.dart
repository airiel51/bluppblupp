import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class BluppAvatar extends StatelessWidget {
  final FinanceState state;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final double borderWidth;
  final Color? borderColor;

  const BluppAvatar({
    super.key,
    required this.state,
    this.size = 56,
    this.onTap,
    this.showEditBadge = false,
    this.borderWidth = 1.8,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppTheme.primaryTeal.withValues(alpha: 0.6);

    Widget avatarContent;

    if (state.hasCustomProfileImage) {
      try {
        final bytes = state.profileImageBytes ??
            (state.profileImageBase64 != null ? base64Decode(state.profileImageBase64!) : null);
        if (bytes != null) {
          avatarContent = ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 2.5).toInt(),
              cacheHeight: (size * 2.5).toInt(),
              errorBuilder: (context, error, stackTrace) => _buildFallback(context),
            ),
          );
        } else {
          avatarContent = _buildFallback(context);
        }
      } catch (_) {
        avatarContent = _buildFallback(context);
      }
    } else if (state.avatarType == 'monogram') {
      avatarContent = _buildMonogram(context);
    } else {
      avatarContent = _buildCharacterPreset(context);
    }

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: avatarContent,
    );

    if (showEditBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(size * 0.07),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.palette_rounded,
                size: (size * 0.22).clamp(11.0, 18.0),
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildCharacterPreset(BuildContext context) {
    final presets = FinanceState.characterAvatarPresets;
    final index = state.avatarPresetIndex.clamp(0, presets.length - 1);
    final preset = presets[index];
    final List<Color> colors = preset['colors'] as List<Color>;
    final IconData icon = preset['icon'] as IconData;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.48,
        ),
      ),
    );
  }

  Widget _buildMonogram(BuildContext context) {
    final gradients = FinanceState.monogramGradients;
    final index = state.monogramColorIndex.clamp(0, gradients.length - 1);
    final List<Color> colors = gradients[index]['colors'] as List<Color>;

    String initial = 'B';
    final name = state.userName.trim();
    if (name.isNotEmpty) {
      initial = name[0].toUpperCase();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.44,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppTheme.textSecondary,
          size: size * 0.52,
        ),
      ),
    );
  }
}

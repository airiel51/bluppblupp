import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Real-time scroll progress bar (0% - 100%) displayed at the top of a scroll view
class BluppScrollProgressBar extends StatelessWidget {
  final ScrollController scrollController;

  const BluppScrollProgressBar({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double progress = 0.0;
        if (scrollController.hasClients &&
            scrollController.position.hasContentDimensions &&
            scrollController.position.maxScrollExtent > 0) {
          progress = (scrollController.offset / scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
        }

        if (progress <= 0.01) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            color: Colors.transparent,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.secondaryCyan],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTealGlow,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Back-to-Top Button that fades in when user scrolls down
class BluppBackToTopButton extends StatelessWidget {
  final ScrollController scrollController;
  final double threshold;

  const BluppBackToTopButton({
    super.key,
    required this.scrollController,
    this.threshold = 240.0,
  });

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final bool show = scrollController.hasClients && scrollController.offset > threshold;

        return IgnorePointer(
          ignoring: !show,
          child: AnimatedScale(
            scale: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _scrollToTop,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.surfaceBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppTheme.isDark ? 0.35 : 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 24,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}

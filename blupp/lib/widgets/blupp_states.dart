import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Interactive card with micro-bounce tactile feedback on tap
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double radius;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.decoration,
    this.radius = 12.0,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: widget.margin,
        decoration: widget.decoration ?? AppTheme.cardDecoration(radius: widget.radius),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.radius),
            onHighlightChanged: (highlighted) {
              setState(() => _isPressed = highlighted);
            },
            onTap: widget.onTap,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer Skeleton loading states
class BluppSkeleton {
  static Widget box({
    required double width,
    required double height,
    double radius = 10,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: AppTheme.surfaceBorder.withValues(alpha: 0.4));
  }

  static Widget netWorthHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              box(width: 110, height: 16),
              box(width: 60, height: 24, radius: 8),
            ],
          ),
          const SizedBox(height: 14),
          box(width: 220, height: 38),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                box(width: 65, height: 28),
                box(width: 65, height: 28),
                box(width: 65, height: 28),
                box(width: 65, height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget bankCardsList() {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 210,
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(width: 32, height: 32, radius: 8),
                  box(width: 40, height: 16),
                ],
              ),
              const Spacer(),
              box(width: 80, height: 12),
              const SizedBox(height: 6),
              box(width: 120, height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget transactionList() {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.cardDecoration(),
          child: Row(
            children: [
              box(width: 40, height: 40, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    box(width: 140, height: 14),
                    const SizedBox(height: 6),
                    box(width: 90, height: 11),
                  ],
                ),
              ),
              box(width: 65, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimalist Emil Kowalski empty state container
class BluppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BluppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Icon(icon, size: 28, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: AppTheme.background,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Explicit error feedback showing WHERE and WHY an issue occurred
class BluppErrorCard extends StatelessWidget {
  final String where;
  final String why;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const BluppErrorCard({
    super.key,
    required this.where,
    required this.why,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.expenseCoral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.expenseCoral.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.expenseCoral,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Error in $where",
                  style: const TextStyle(
                    color: AppTheme.expenseCoral,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              why,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: GestureDetector(
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh_rounded, size: 14, color: AppTheme.primaryTeal),
                    SizedBox(width: 4),
                    Text(
                      "Try Again",
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

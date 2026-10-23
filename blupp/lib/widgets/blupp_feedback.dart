import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Standardized Toast notifications for Success and Error messages
class BluppToast {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.incomeMint.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.incomeMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFECFDF5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF7F1D1D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.expenseCoral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFFEF2F2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// In-form Success Banner (e.g. after submission)
class BluppSuccessCard extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onDismiss;

  const BluppSuccessCard({
    super.key,
    required this.title,
    this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.incomeMint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.incomeMint.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.incomeMint.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.incomeMint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.incomeMint,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    message!,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}

/// In-form Error Banner (e.g. invalid fields or submission failure)
class BluppErrorCard extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onDismiss;

  const BluppErrorCard({
    super.key,
    required this.title,
    this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.expenseCoral.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.expenseCoral.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 18, color: AppTheme.expenseCoral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.expenseCoral,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    message!,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}

/// Polished confirmation modal dialog
class BluppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  const BluppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => BluppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = isDestructive ? AppTheme.expenseCoral : AppTheme.primaryTeal;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? (isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded),
                      size: 20,
                      color: actionColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(cancelLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: isDestructive ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1-tap Copy Button with visual checkmark feedback
class BluppCopyButton extends StatefulWidget {
  final String textToCopy;
  final String? tooltip;
  final String? label;
  final Color? color;
  final double size;

  const BluppCopyButton({
    super.key,
    required this.textToCopy,
    this.tooltip = 'Copy to clipboard',
    this.label,
    this.color,
    this.size = 18.0,
  });

  @override
  State<BluppCopyButton> createState() => _BluppCopyButtonState();
}

class _BluppCopyButtonState extends State<BluppCopyButton> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    if (mounted) {
      setState(() => _copied = true);
      BluppToast.showSuccess(context, 'Copied to clipboard');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? (_copied ? AppTheme.incomeMint : AppTheme.textMuted);

    if (widget.label != null) {
      return TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: effectiveColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        onPressed: _handleCopy,
        icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: widget.size),
        label: Text(
          _copied ? 'Copied' : widget.label!,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    return IconButton(
      tooltip: widget.tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey(_copied),
          size: widget.size,
          color: effectiveColor,
        ),
      ),
      onPressed: _handleCopy,
    );
  }
}

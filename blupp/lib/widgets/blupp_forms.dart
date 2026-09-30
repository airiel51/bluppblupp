import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean horizontal boxed segment selector (e.g. [ Expense ] [ Income ])
class BluppBoxedSegment<T> extends StatelessWidget {
  final T selectedValue;
  final List<BluppSegmentItem<T>>? items;
  final List<dynamic>? options;
  final ValueChanged<T>? onSelected;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;

  const BluppBoxedSegment({
    super.key,
    required this.selectedValue,
    this.items,
    this.options,
    this.onSelected,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<BluppSegmentItem<T>> resolvedItems = [];
    if (items != null) {
      resolvedItems.addAll(items!);
    } else if (options != null) {
      for (final opt in options!) {
        if (opt is BluppSegmentItem<T>) {
          resolvedItems.add(opt);
        } else if (opt is Map) {
          resolvedItems.add(BluppSegmentItem<T>(
            value: opt['value'] as T,
            label: opt['label']?.toString() ?? '',
            icon: opt['icon'] as IconData?,
            activeColor: (opt['activeColor'] as Color?) ?? activeColor,
          ));
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: resolvedItems.map((item) {
          final isSelected = item.value == selectedValue;
          final color = isSelected
              ? (item.activeColor ?? activeColor ?? AppTheme.textPrimary)
              : AppTheme.textMuted;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onChanged?.call(item.value);
                onSelected?.call(item.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppTheme.surfaceBorder)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 15,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BluppSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? activeColor;

  const BluppSegmentItem({
    required this.value,
    required this.label,
    this.icon,
    this.activeColor,
  });
}

/// Horizontal scrollable boxed option selector (e.g. select bank account or categories)
class BluppHorizontalBoxPicker<T> extends StatelessWidget {
  final String? label;
  final List<T>? items;
  final List<dynamic>? options;
  final T? selectedItem;
  final T? selectedValue;
  final String Function(T)? itemLabel;
  final IconData? Function(T)? itemIcon;
  final Color? Function(T)? itemColor;
  final ValueChanged<T>? onSelected;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;

  const BluppHorizontalBoxPicker({
    super.key,
    this.label,
    this.items,
    this.options,
    this.selectedItem,
    this.selectedValue,
    this.itemLabel,
    this.itemIcon,
    this.itemColor,
    this.onSelected,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelected = selectedValue ?? selectedItem;

    Widget buildRow() {
      if (options != null) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: options!.map((opt) {
              T val;
              String lbl;
              IconData? ic;
              Color clr;

              if (opt is Map) {
                val = opt['value'] as T;
                lbl = opt['label']?.toString() ?? '';
                ic = opt['icon'] as IconData?;
                clr = (opt['color'] as Color?) ?? activeColor ?? AppTheme.primaryTeal;
              } else {
                val = opt as T;
                lbl = val.toString();
                ic = null;
                clr = activeColor ?? AppTheme.primaryTeal;
              }

              final isSelected = val == effectiveSelected;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    onChanged?.call(val);
                    onSelected?.call(val);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? (activeColor ?? clr) : AppTheme.surfaceBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ic != null) ...[
                          Icon(ic, size: 14, color: isSelected ? clr : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          lbl,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }

      if (items != null) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: items!.map((item) {
              final isSelected = item == effectiveSelected;
              final color = itemColor?.call(item) ?? activeColor ?? AppTheme.primaryTeal;
              final icon = itemIcon?.call(item);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    onChanged?.call(item);
                    onSelected?.call(item);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? (activeColor ?? AppTheme.primaryTeal) : AppTheme.surfaceBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 14, color: isSelected ? color : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          itemLabel != null ? itemLabel!(item) : item.toString(),
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }

      return const SizedBox.shrink();
    }

    if (label != null && label!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          buildRow(),
        ],
      );
    }

    return buildRow();
  }
}

/// 6-Box Horizontal Verification Code (OTP) Input
class BluppBoxedOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const BluppBoxedOtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<BluppBoxedOtpInput> createState() => _BluppBoxedOtpInputState();
}

class _BluppBoxedOtpInputState extends State<BluppBoxedOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        _controllers[index].text = value.substring(value.length - 1);
      }
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _controllers[index].text.isNotEmpty
                  ? AppTheme.primaryTeal
                  : AppTheme.surfaceBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _onDigitChanged(index, val),
            ),
          ),
        );
      }),
    );
  }
}

/// Explicit Where and Why error indicator shown under form fields or at top of forms
class BluppFieldError extends StatelessWidget {
  final String? where;
  final String? why;
  final String? fieldName;
  final String? errorMessage;

  const BluppFieldError({
    super.key,
    this.where,
    this.why,
    this.fieldName,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWhere = where ?? fieldName ?? "Form Field";
    final effectiveWhy = why ?? errorMessage;

    if (effectiveWhy == null || effectiveWhy.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.expenseCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.expenseCoral.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline_rounded, size: 15, color: AppTheme.expenseCoral),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseCoral.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "WHERE: $effectiveWhere",
                        style: const TextStyle(
                          color: AppTheme.expenseCoral,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: AppTheme.expenseCoral, height: 1.3),
                    children: [
                      const TextSpan(
                        text: "WHY: ",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: effectiveWhy,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

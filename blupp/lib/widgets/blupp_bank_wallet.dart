import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

/// Custom clipper that creates the docked cutout notch at the bottom right
/// matching the DailyFlutterUI wallet design.
class BankCardCutoutClipper extends CustomClipper<Path> {
  final double cutoutWidth;
  final double cutoutHeight;
  final double cornerRadius;
  final double notchRadius;

  const BankCardCutoutClipper({
    this.cutoutWidth = 136,
    this.cutoutHeight = 48,
    this.cornerRadius = 22,
    this.notchRadius = 14,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final nr = notchRadius;
    final cutoutTop = h - cutoutHeight;
    final cutoutLeft = w - cutoutWidth;

    final path = Path();
    path.moveTo(r, 0);

    // Top edge
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    // Right edge down to before cutout notch
    path.lineTo(w, cutoutTop - nr);
    path.quadraticBezierTo(w, cutoutTop, w - nr, cutoutTop);

    // Cutout shelf towards left
    path.lineTo(cutoutLeft + nr, cutoutTop);
    path.quadraticBezierTo(cutoutLeft, cutoutTop, cutoutLeft, cutoutTop + nr);

    // Down to bottom edge
    path.lineTo(cutoutLeft, h - r);
    path.quadraticBezierTo(cutoutLeft, h, cutoutLeft - r, h);

    // Bottom edge towards left
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    // Left edge
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant BankCardCutoutClipper oldClipper) =>
      oldClipper.cutoutWidth != cutoutWidth ||
      oldClipper.cutoutHeight != cutoutHeight ||
      oldClipper.cornerRadius != cornerRadius;
}

enum _WatermarkType { stripes, mesh, islamic, waves, cyber, standard }

/// Custom painter rendering bank-specific card watermarks and textures
class _CardWatermarkPainter extends CustomPainter {
  final _WatermarkType type;
  final Color color;

  const _CardWatermarkPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    switch (type) {
      case _WatermarkType.stripes:
        // Iconic Maybank dual-tone diagonal bands
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(size.width * 0.42, 0)
          ..lineTo(size.width * 0.62, 0)
          ..lineTo(size.width * 0.32, size.height)
          ..lineTo(size.width * 0.12, size.height)
          ..close();
        canvas.drawPath(path, fillPaint);
        final path2 = Path()
          ..moveTo(size.width * 0.68, 0)
          ..lineTo(size.width * 0.76, 0)
          ..lineTo(size.width * 0.46, size.height)
          ..lineTo(size.width * 0.38, size.height)
          ..close();
        canvas.drawPath(path2, fillPaint);
        break;

      case _WatermarkType.mesh:
        // CIMB carbon diagonal micro-mesh
        for (double x = -size.height; x < size.width + size.height; x += 16) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x + size.height * 0.6, size.height),
            paint..strokeWidth = 0.9,
          );
        }
        break;

      case _WatermarkType.islamic:
        // Bank Islam concentric geometric arch arcs
        final center = Offset(size.width * 0.82, size.height * 0.35);
        for (double r = 24; r < 150; r += 22) {
          canvas.drawCircle(center, r, paint..strokeWidth = 1.0);
        }
        break;

      case _WatermarkType.waves:
        // RHB and Touch 'n Go fluid gradient waves
        final path = Path();
        path.moveTo(0, size.height * 0.6);
        path.cubicTo(
          size.width * 0.35,
          size.height * 0.3,
          size.width * 0.65,
          size.height * 0.9,
          size.width,
          size.height * 0.5,
        );
        canvas.drawPath(path, paint..strokeWidth = 2.0);
        final path2 = Path();
        path2.moveTo(0, size.height * 0.8);
        path2.cubicTo(
          size.width * 0.4,
          size.height * 0.5,
          size.width * 0.7,
          size.height * 1.0,
          size.width,
          size.height * 0.7,
        );
        canvas.drawPath(path2, paint);
        break;

      case _WatermarkType.cyber:
        // GXBank neon cyber circuit nodes
        final p = Path()
          ..moveTo(size.width * 0.25, 0)
          ..lineTo(size.width * 0.25, size.height * 0.45)
          ..lineTo(size.width * 0.65, size.height * 0.75)
          ..lineTo(size.width, size.height * 0.75);
        canvas.drawPath(p, paint..strokeWidth = 1.6);
        canvas.drawCircle(
          Offset(size.width * 0.65, size.height * 0.75),
          4,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
        break;

      case _WatermarkType.standard:
        canvas.drawCircle(
          Offset(size.width * 0.85, size.height * 0.25),
          75,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CardWatermarkPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}

/// Helper to resolve designated bank styling, brand logos, and network indicators
class _BankCardProfile {
  final String brandName;
  final String cardNetwork; // 'VISA', 'MASTERCARD'
  final String expiry;
  final LinearGradient gradient;
  final Color accentColor;
  final bool isLight;
  final bool isGoldChip;
  final _WatermarkType watermark;
  final String cardTier;
  final IconData brandIcon;

  const _BankCardProfile({
    required this.brandName,
    required this.cardNetwork,
    required this.expiry,
    required this.gradient,
    required this.accentColor,
    required this.isLight,
    required this.isGoldChip,
    required this.watermark,
    required this.cardTier,
    required this.brandIcon,
  });

  static LinearGradient _createGradient(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final midColor = hsl.withLightness((hsl.lightness * 0.72).clamp(0.12, 0.6)).toColor();
    final darkColor = hsl.withLightness((hsl.lightness * 0.40).clamp(0.06, 0.35)).toColor();
    const deepShadow = Color(0xFF0D1117);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        midColor,
        darkColor,
        deepShadow,
      ],
      stops: const [0.0, 0.45, 0.85, 1.0],
    );
  }

  static _BankCardProfile forBank(BankAccount bank) {
    final nameLower = bank.name.toLowerCase();
    final baseColor = bank.color;
    final isLuminanceLight = baseColor.computeLuminance() > 0.42;
    final cardGradient = _createGradient(baseColor);

    // 1. Maybank - Signature Striped Card
    if (nameLower.contains('maybank') || nameLower.contains('harimau')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'VISA',
        expiry: '08/28',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: true,
        watermark: _WatermarkType.stripes,
        cardTier: 'VISA PLATINUM',
        brandIcon: Icons.account_balance_rounded,
        gradient: cardGradient,
      );
    }

    // 2. CIMB Bank - Signature Carbon Mesh Card
    if (nameLower.contains('cimb')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'MASTERCARD',
        expiry: '04/27',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: false,
        watermark: _WatermarkType.mesh,
        cardTier: 'MASTERCARD WORLD',
        brandIcon: Icons.account_balance_rounded,
        gradient: cardGradient,
      );
    }

    // 3. Bank Islam / Muamalat - Concentric Arch Geometric Card
    if (nameLower.contains('islam') || nameLower.contains('muamalat')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'VISA',
        expiry: '11/29',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: true,
        watermark: _WatermarkType.islamic,
        cardTier: 'VISA DEBIT-i',
        brandIcon: Icons.account_balance_rounded,
        gradient: cardGradient,
      );
    }

    // 4. RHB Bank - Fluid Wave Card
    if (nameLower.contains('rhb')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'VISA',
        expiry: '06/28',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: false,
        watermark: _WatermarkType.waves,
        cardTier: 'VISA SIGNATURE',
        brandIcon: Icons.account_balance_rounded,
        gradient: cardGradient,
      );
    }

    // 5. GXBank - Cyber Neon Circuit Card
    if (nameLower.contains('gx') || nameLower.contains('gxbank')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'MASTERCARD',
        expiry: '01/30',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: false,
        watermark: _WatermarkType.cyber,
        cardTier: 'DIGITAL DEBIT',
        brandIcon: Icons.bolt_rounded,
        gradient: cardGradient,
      );
    }

    // 6. Touch 'n Go - Contactless Wave Card
    if (nameLower.contains('touch') || nameLower.contains('tng')) {
      return _BankCardProfile(
        brandName: bank.name,
        cardNetwork: 'VISA',
        expiry: '09/27',
        accentColor: baseColor,
        isLight: isLuminanceLight,
        isGoldChip: false,
        watermark: _WatermarkType.waves,
        cardTier: 'VISA PREPAID',
        brandIcon: Icons.contactless_rounded,
        gradient: cardGradient,
      );
    }

    // Dynamic tailored profile for any custom bank (Aeon Bank, Public Bank, HSBC, etc.)
    return _BankCardProfile(
      brandName: bank.name,
      cardNetwork: (bank.name.length % 2 == 0) ? 'VISA' : 'MASTERCARD',
      expiry: '12/28',
      accentColor: baseColor,
      isLight: isLuminanceLight,
      isGoldChip: isLuminanceLight,
      watermark: _WatermarkType.standard,
      cardTier: 'DEBIT CARD',
      brandIcon: bank.icon,
      gradient: cardGradient,
    );
  }
}

/// Tiered stacked bank cards wallet with true physics-inspired "bring designated card to front"
/// and zero-overflow phone responsive layout.
class BluppBankWallet extends StatefulWidget {
  final FinanceState state;
  final Function(BankAccount) onManageBank;
  final Function(BankAccount) onAddMoney;
  final Function(BankAccount) onMinusMoney;
  final VoidCallback onAddNewCard;

  const BluppBankWallet({
    super.key,
    required this.state,
    required this.onManageBank,
    required this.onAddMoney,
    required this.onMinusMoney,
    required this.onAddNewCard,
  });

  @override
  State<BluppBankWallet> createState() => _BluppBankWalletState();
}

class _BluppBankWalletState extends State<BluppBankWallet>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  int? _fromIndex;
  int? _toIndex;
  Offset _dragOffset = Offset.zero;

  late final AnimationController _animController;
  late final Animation<double> _curvedAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    widget.state.addListener(_onStateChanged);

    // Sync initial selectedBankId if set in state
    final selectedId = widget.state.selectedBankId;
    if (selectedId != null) {
      final idx = widget.state.bankAccounts.indexWhere((b) => b.id == selectedId);
      if (idx != -1) _activeIndex = idx;
    }
  }

  @override
  void didUpdateWidget(covariant BluppBankWallet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_onStateChanged);
      widget.state.addListener(_onStateChanged);
    }
    _checkExternalSelection();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    _checkExternalSelection();
  }

  void _checkExternalSelection() {
    final accounts = widget.state.bankAccounts;
    if (accounts.isEmpty) return;

    final selectedId = widget.state.selectedBankId;
    if (selectedId != null) {
      final idx = accounts.indexWhere((b) => b.id == selectedId);
      if (idx != -1 && idx != _activeIndex && !_animController.isAnimating) {
        _bringToFront(idx);
      }
    } else if (_activeIndex >= accounts.length) {
      setState(() => _activeIndex = 0);
    }
  }

  /// Brings the designated card physically from its slot in the back to the front
  void _bringToFront(int targetIndex) {
    final accounts = widget.state.bankAccounts;
    if (accounts.isEmpty) return;
    final normalized = targetIndex % accounts.length;
    if (normalized == _activeIndex && _toIndex == null) return;
    if (_animController.isAnimating) return;

    HapticFeedback.selectionClick();

    setState(() {
      _dragOffset = Offset.zero;
      _fromIndex = _activeIndex;
      _toIndex = normalized;
    });

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _activeIndex = normalized;
          _fromIndex = null;
          _toIndex = null;
        });
        _animController.reset();
        widget.state.setSelectedBankId(accounts[_activeIndex].id);
      }
    });
  }

  void _nextCard() {
    final accounts = widget.state.bankAccounts;
    if (accounts.isEmpty) return;
    _bringToFront((_activeIndex + 1) % accounts.length);
  }

  void _prevCard() {
    final accounts = widget.state.bankAccounts;
    if (accounts.isEmpty) return;
    _bringToFront((_activeIndex - 1 + accounts.length) % accounts.length);
  }

  String _cleanLast4(String raw, String fallback) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return fallback;
  }

  double _getSlotTop(int slot) {
    if (slot == 0) return 56.0;
    if (slot == 1) return 28.0;
    return 0.0;
  }

  double _getSlotScale(int slot) {
    if (slot == 0) return 1.0;
    if (slot == 1) return 0.96;
    return 0.92;
  }

  int _calculateSlot(int cardIndex, int frontIndex, int total) {
    return (cardIndex - frontIndex + total) % total;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.state.bankAccounts;
    final bool hasRealAccounts = accounts.isNotEmpty;
    final totalAccounts = hasRealAccounts ? accounts.length : 1;

    // Fallback card if empty
    final defaultBank = BankAccount(
      id: 'mb_1',
      name: 'Maybank',
      accountNumber: '•••• 8921',
      balance: 4250.00,
      color: const Color(0xFFFFB800),
      icon: Icons.account_balance,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardWidth = availableWidth.isFinite
            ? availableWidth.clamp(280.0, 520.0)
            : 440.0;
        final cardHeight = (cardWidth * 0.56).clamp(168.0, 215.0);
        final cutoutWidth = (cardWidth * 0.35).clamp(115.0, 140.0);
        const cutoutHeight = 46.0;
        final deckHeight = cardHeight + 72.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gesture-enabled horizontal swipe & stacked card deck (clean drag with zero tap conflict)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) {
                    if (_animController.isAnimating) return;
                    _dragOffset = Offset.zero;
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_animController.isAnimating) return;
                    setState(() {
                      _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_animController.isAnimating) return;
                    final dx = _dragOffset.dx;
                    final vx = details.primaryVelocity ?? 0.0;
                    if (dx < -55 || vx < -220) {
                      _nextCard();
                    } else if (dx > 55 || vx > 220) {
                      _prevCard();
                    }
                    if (_dragOffset != Offset.zero) {
                      setState(() {
                        _dragOffset = Offset.zero;
                      });
                    }
                  },
                  child: SizedBox(
                    height: deckHeight,
                    child: AnimatedBuilder(
                      animation: _curvedAnim,
                      builder: (context, _) {
                        final t = _curvedAnim.value;
                        final isAnimating = _toIndex != null && _fromIndex != null;

                        // Build list of stack children with correct physical Z-ordering
                        final List<Widget> stackChildren = [];

                        if (!hasRealAccounts) {
                          // Single default card
                          stackChildren.add(
                            Positioned(
                              top: 56.0,
                              left: 0,
                              right: 0,
                              height: cardHeight,
                              child: _buildCardFace(
                                context: context,
                                bank: defaultBank,
                                cardIndex: 0,
                                isFront: true,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                cutoutWidth: cutoutWidth,
                                cutoutHeight: cutoutHeight,
                              ),
                            ),
                          );
                        } else if (!isAnimating) {
                          // Rest state: Order from back (slot >= 2) -> middle (slot 1) -> front (slot 0)
                          final cardIndices = List.generate(totalAccounts, (i) => i);
                          cardIndices.sort((a, b) {
                            final slotA = _calculateSlot(a, _activeIndex, totalAccounts);
                            final slotB = _calculateSlot(b, _activeIndex, totalAccounts);
                            return slotB.compareTo(slotA); // Higher slot (back) rendered first
                          });

                          final isDragging = _dragOffset != Offset.zero;
                          final dragProgress = (_dragOffset.dx.abs() / 160.0).clamp(0.0, 1.0);

                          for (final idx in cardIndices) {
                            final slot = _calculateSlot(idx, _activeIndex, totalAccounts);
                            if (slot > 2) continue; // Only peek up to 3 cards in the deck

                            double top = _getSlotTop(slot);
                            double scale = _getSlotScale(slot);
                            final isFront = slot == 0;

                            // Dynamic lift of card beneath while user drags the front card
                            if (slot == 1 && isDragging) {
                              top = lerpDouble(top, 46.0, dragProgress * 0.7)!;
                              scale = lerpDouble(scale, 1.0, dragProgress * 0.6)!;
                            }

                            Widget cardWidget = _buildCardFace(
                              context: context,
                              bank: accounts[idx],
                              cardIndex: idx,
                              isFront: isFront,
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              cutoutWidth: cutoutWidth,
                              cutoutHeight: cutoutHeight,
                            );

                            // Interactive live tilt and translation on the front card while dragging
                            if (isFront && isDragging) {
                              final dragAngle = (_dragOffset.dx / 550.0).clamp(-0.16, 0.16);
                              cardWidget = Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.translationValues(
                                  _dragOffset.dx * 0.85,
                                  _dragOffset.dy * 0.25,
                                  0.0,
                                )..rotateZ(dragAngle),
                                child: cardWidget,
                              );
                            }

                            stackChildren.add(
                              Positioned(
                                top: top,
                                left: 0,
                                right: 0,
                                height: cardHeight,
                                child: Transform.scale(
                                  scale: scale,
                                  alignment: Alignment.topCenter,
                                  child: cardWidget,
                                ),
                              ),
                            );
                          }
                        } else {
                      // Transition state: Incoming card physically lifts and flies on top!
                      final incomingIdx = _toIndex!;
                      final outgoingIdx = _fromIndex!;

                      // 1. Static/background cards (rendered first at bottom of stack)
                      for (int idx = 0; idx < totalAccounts; idx++) {
                        if (idx == incomingIdx || idx == outgoingIdx) continue;

                        final startSlot = _calculateSlot(idx, outgoingIdx, totalAccounts);
                        final endSlot = _calculateSlot(idx, incomingIdx, totalAccounts);
                        if (startSlot > 2 && endSlot > 2) continue;

                        final top = lerpDouble(_getSlotTop(startSlot), _getSlotTop(endSlot), t)!;
                        final scale = lerpDouble(_getSlotScale(startSlot), _getSlotScale(endSlot), t)!;

                        stackChildren.add(
                          Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            height: cardHeight,
                            child: Transform.scale(
                              scale: scale,
                              alignment: Alignment.topCenter,
                              child: _buildCardFace(
                                context: context,
                                bank: accounts[idx],
                                cardIndex: idx,
                                isFront: false,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                cutoutWidth: cutoutWidth,
                                cutoutHeight: cutoutHeight,
                              ),
                            ),
                          ),
                        );
                      }

                      // 2. Outgoing card (glides back into the stack)
                      final outStartSlot = 0;
                      final outEndSlot = _calculateSlot(outgoingIdx, incomingIdx, totalAccounts);
                      final outTop = lerpDouble(_getSlotTop(outStartSlot), _getSlotTop(outEndSlot), t)!;
                      final outScale = lerpDouble(_getSlotScale(outStartSlot), _getSlotScale(outEndSlot), t)!;

                      stackChildren.add(
                        Positioned(
                          top: outTop,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: Transform.scale(
                            scale: outScale,
                            alignment: Alignment.topCenter,
                            child: _buildCardFace(
                              context: context,
                              bank: accounts[outgoingIdx],
                              cardIndex: outgoingIdx,
                              isFront: t < 0.45,
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              cutoutWidth: cutoutWidth,
                              cutoutHeight: cutoutHeight,
                            ),
                          ),
                        ),
                      );

                      // 3. Incoming card (physically arcs up in 3D and swoops to front, on TOP of all cards!)
                      final inStartSlot = _calculateSlot(incomingIdx, outgoingIdx, totalAccounts);
                      final inStartTop = _getSlotTop(inStartSlot);
                      final inStartScale = _getSlotScale(inStartSlot);

                      // High arc-lift so the card visibly peels out of the deck and glides over
                      final arcLift = math.sin(t * math.pi) * 36.0;
                      final inTop = lerpDouble(inStartTop, 56.0, t)! - arcLift;
                      final inScale = lerpDouble(inStartScale, 1.0, t)! + (math.sin(t * math.pi) * 0.05);

                      stackChildren.add(
                        Positioned(
                          top: inTop,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: Transform.scale(
                            scale: inScale,
                            alignment: Alignment.topCenter,
                            child: _buildCardFace(
                              context: context,
                              bank: accounts[incomingIdx],
                              cardIndex: incomingIdx,
                              isFront: t > 0.40,
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              cutoutWidth: cutoutWidth,
                              cutoutHeight: cutoutHeight,
                            ),
                          ),
                        ),
                      );
                    }

                    // 4. DOCKED "+ Add Card" PILL BUTTON (Nestled in the front card's notch)
                    stackChildren.add(
                      Positioned(
                        top: 56.0 + (cardHeight - cutoutHeight) + 2,
                        right: 3,
                        width: cutoutWidth - 6,
                        height: cutoutHeight - 4,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Material(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(22),
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.5),
                            child: InkWell(
                              onTap: widget.onAddNewCard,
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle, color: Colors.white, size: 15),
                                      SizedBox(width: 5),
                                      Text(
                                        "Add Card",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: stackChildren,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Bank Account Interactive Selector Row (Phone-optimized 1-tap switching)
            _buildBankAccountSelectorRow(accounts, _activeIndex),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Renders a real, fully styled bank card with its designated bank colors, watermark,
  /// EMV chip, balance, brand logos, and action buttons.
  Widget _buildCardFace({
    required BuildContext context,
    required BankAccount bank,
    required int cardIndex,
    required bool isFront,
    required double cardWidth,
    required double cardHeight,
    required double cutoutWidth,
    required double cutoutHeight,
  }) {
    final profile = _BankCardProfile.forBank(bank);
    final state = widget.state;
    final userName = state.userName.isNotEmpty
        ? state.userName.toUpperCase()
        : "DAILYFLUTTERUI";
    final last4 = _cleanLast4(bank.accountNumber, "8921");

    final textColor = profile.isLight ? const Color(0xFF111827) : Colors.white;
    final textMuted = profile.isLight ? const Color(0xFF374151) : Colors.white70;
    final textSubtle = profile.isLight ? const Color(0xFF4B5563) : Colors.white60;
    final chipBg = profile.isLight
        ? Colors.black.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.18);
    final btnBg = profile.isLight
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.22);
    final btnBorder = profile.isLight
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.32);
    final watermarkColor = profile.isLight
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.10);

    final cardContent = Stack(
      children: [
        // 1. Bank Custom Watermark (Stripes for Maybank, Mesh for CIMB, Star for Bank Islam, etc.)
        Positioned.fill(
          child: CustomPaint(
            painter: _CardWatermarkPainter(
              type: profile.watermark,
              color: watermarkColor,
            ),
          ),
        ),

        // 2. Card Content Layout
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Brand pill badge + Palette icon + Last 4 digits + Network Brand Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: profile.isLight
                                  ? Colors.black.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.20),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(profile.brandIcon, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  profile.brandName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isFront)
                          InkWell(
                            onTap: () => widget.onManageBank(bank),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Icon(
                                Icons.palette_outlined,
                                size: 14,
                                color: textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "•••• $last4",
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12.5,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildNetworkBrandLogo(profile.cardNetwork, textColor),
                    ],
                  ),
                ],
              ),

              // Middle Row: Metallic Chip + Balance Metric + Quick Actions (Add/Minus)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _buildMetallicEMVChip(profile.isGoldChip),
                            const SizedBox(width: 6),
                            Icon(Icons.contactless_rounded, size: 14, color: textMuted),
                            const SizedBox(width: 6),
                            Text(
                              "Balance",
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppTheme.formatCurrency(bank.balance),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick Add / Minus action buttons on front card
                  if (isFront)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onAddMoney(bank),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: btnBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: btnBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 13, color: textColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    "Add",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onMinusMoney(bank),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: btnBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: btnBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_rounded, size: 13, color: textColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    "Minus",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Bottom Row: Cardholder Name + Expiry Date + Card Tier
              Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CARDHOLDER",
                          style: TextStyle(
                            color: textSubtle,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          userName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EXPIRES",
                        style: TextStyle(
                          color: textSubtle,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        profile.expiry,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    profile.cardTier,
                    style: TextStyle(
                      color: textSubtle,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // Front card uses BankCardCutoutClipper for the docked notch
    // Rear cards use clean rounded corners
    final Widget cardShape = isFront
        ? ClipPath(
            clipper: BankCardCutoutClipper(
              cutoutWidth: cutoutWidth,
              cutoutHeight: cutoutHeight,
              cornerRadius: 22,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: profile.gradient,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onManageBank(bank),
                  child: cardContent,
                ),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                gradient: profile.gradient,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _bringToFront(cardIndex),
                  child: cardContent,
                ),
              ),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: profile.accentColor.withValues(alpha: profile.isLight ? 0.35 : 0.45),
            blurRadius: isFront ? 18 : 10,
            offset: Offset(0, isFront ? 8 : 4),
          ),
        ],
      ),
      child: cardShape,
    );
  }

  /// Authentic metallic EMV chip with internal circuit contact pads
  Widget _buildMetallicEMVChip(bool isGoldChip) {
    final chipBorder = isGoldChip ? const Color(0xFFB3923C) : const Color(0xFF9E9E9E);
    final chipInnerBorder = isGoldChip ? const Color(0xFF8C7126) : const Color(0xFF757575);
    final chipColors = isGoldChip
        ? const [Color(0xFFFFEEA8), Color(0xFFDFBF66), Color(0xFFB89638)]
        : const [Color(0xFFF5F5F5), Color(0xFFD6D6D6), Color(0xFFA8A8A8)];

    return Container(
      width: 24,
      height: 18,
      decoration: BoxDecoration(
        color: isGoldChip ? const Color(0xFFE0C475) : const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipBorder, width: 0.8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: chipColors,
        ),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: chipInnerBorder, width: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(width: 0.6, color: chipInnerBorder),
              Container(width: 0.6, color: chipInnerBorder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkBrandLogo(String network, Color textColor) {
    if (network == 'MASTERCARD') {
      return SizedBox(
        width: 30,
        height: 18,
        child: Stack(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              left: 11,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      "VISA",
      style: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Clean, modern horizontal selector showing each designated bank account.
  /// Tapping ANY bank brings that designated card directly to the front!
  Widget _buildBankAccountSelectorRow(List<BankAccount> accounts, int activeIndex) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(accounts.length, (index) {
          final isSelected = index == activeIndex;
          final bank = accounts[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _bringToFront(index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? bank.color.withValues(alpha: 0.18)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? bank.color.withValues(alpha: 0.85)
                            : AppTheme.surfaceBorder.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: bank.color,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: bank.color.withValues(alpha: 0.7),
                                      blurRadius: 5,
                                      spreadRadius: 0.5,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bank.name,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppTheme.formatCurrency(bank.balance),
                          style: TextStyle(
                            color: isSelected ? bank.color : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
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
    this.cutoutWidth = 144,
    this.cutoutHeight = 52,
    this.cornerRadius = 24,
    this.notchRadius = 16,
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
    // Start at top-left after corner
    path.moveTo(r, 0);

    // Top edge
    path.lineTo(w - r, 0);
    // Top-right corner
    path.quadraticBezierTo(w, 0, w, r);

    // Right edge down to before cutout notch
    path.lineTo(w, cutoutTop - nr);
    // Concave inward curve to cutout shelf
    path.quadraticBezierTo(w, cutoutTop, w - nr, cutoutTop);

    // Cutout shelf towards left
    path.lineTo(cutoutLeft + nr, cutoutTop);
    // Downward curve to cutout left edge
    path.quadraticBezierTo(cutoutLeft, cutoutTop, cutoutLeft, cutoutTop + nr);

    // Down to bottom edge
    path.lineTo(cutoutLeft, h - r);
    // Curve to bottom line
    path.quadraticBezierTo(cutoutLeft, h, cutoutLeft - r, h);

    // Bottom edge towards left
    path.lineTo(r, h);
    // Bottom-left corner
    path.quadraticBezierTo(0, h, 0, h - r);

    // Left edge
    path.lineTo(0, r);
    // Top-left corner
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

/// Tiered stacked bank cards wallet matching the user-requested reference image
/// with smooth physics-inspired "bring card to front" animation.
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
  int _frontIndex = 0;
  int? _animatingTargetIndex;
  late final AnimationController _animController;
  late final Animation<double> _curvedAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _bringToFront(int targetIndex) {
    final accounts = widget.state.bankAccounts;
    if (accounts.isEmpty && targetIndex == _frontIndex) return;
    if (accounts.isNotEmpty && (targetIndex % accounts.length) == _frontIndex) return;
    if (_animController.isAnimating) return;

    setState(() {
      _animatingTargetIndex = targetIndex;
    });

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _frontIndex = targetIndex;
          _animatingTargetIndex = null;
        });
        _animController.reset();
      }
    });
  }

  void _nextCard() {
    final accounts = widget.state.bankAccounts;
    final total = accounts.isNotEmpty ? accounts.length : 3;
    _bringToFront((_frontIndex + 1) % total);
  }

  void _prevCard() {
    final accounts = widget.state.bankAccounts;
    final total = accounts.isNotEmpty ? accounts.length : 3;
    _bringToFront((_frontIndex - 1 + total) % total);
  }

  String _cleanLast4(String raw, String fallback) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.state.bankAccounts;
    final bool hasRealAccounts = accounts.isNotEmpty;

    final activeIndex = hasRealAccounts ? (_frontIndex % accounts.length) : 0;
    final activeBank = hasRealAccounts
        ? accounts[activeIndex]
        : BankAccount(
            id: 'default_card',
            name: widget.state.userName.isNotEmpty ? widget.state.userName : 'dailyflutterui',
            accountNumber: '•••• 7845',
            balance: 56782.80,
            color: const Color(0xFF5856D6),
            icon: Icons.credit_card,
          );

    final backBank = accounts.length > 2
        ? accounts[(activeIndex + 2) % accounts.length]
        : (accounts.length > 1 ? accounts[(activeIndex + 1) % accounts.length] : null);

    final middleBank = accounts.length > 1
        ? accounts[(activeIndex + 1) % accounts.length]
        : null;

    const deckHeight = 280.0;
    const cardHeight = 200.0;
    const cutoutWidth = 144.0;
    const cutoutHeight = 52.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gesture-enabled stacked card deck
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -180) {
                    _nextCard();
                  } else if (details.primaryVelocity! > 180) {
                    _prevCard();
                  }
                }
              },
              child: SizedBox(
                height: deckHeight,
                child: AnimatedBuilder(
                  animation: _curvedAnim,
                  builder: (context, _) {
                    final t = _curvedAnim.value;
                    final isSwitching = _animatingTargetIndex != null;

                    // Compute dynamic positions during card-switch animation
                    double backTop = 0;
                    double middleTop = 36;
                    double frontTop = 72;

                    double backScale = 0.95;
                    double middleScale = 0.98;
                    double frontScale = 1.0;

                    // If a switch is in progress, smoothly interpolate positions
                    if (isSwitching) {
                      // Front card glides back
                      frontTop = 72 - (36 * t);
                      frontScale = 1.0 - (0.02 * t);

                      // Middle card arcs up into the air and drops into the front slot
                      final arcLift = math.sin(t * math.pi) * 28.0;
                      middleTop = 36 + (36 * t) - arcLift;
                      middleScale = 0.98 + (0.02 * t);
                    }

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. BACK CARD (Green VISA)
                        Positioned(
                          top: backTop,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: Transform.scale(
                            scale: backScale,
                            child: _buildBackCard(
                              bank: backBank,
                              color: const Color(0xFF0D5C46), // Deep Emerald
                              brand: "VISA",
                              last4: backBank != null
                                  ? _cleanLast4(backBank.accountNumber, "9312")
                                  : "9312",
                              onTap: () {
                                if (hasRealAccounts && backBank != null) {
                                  _bringToFront(accounts.indexOf(backBank));
                                } else {
                                  _nextCard();
                                }
                              },
                            ),
                          ),
                        ),

                        // 2. MIDDLE CARD (Amber / Bronze Mastercard)
                        Positioned(
                          top: middleTop,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: Transform.scale(
                            scale: middleScale,
                            child: _buildMiddleCard(
                              bank: middleBank,
                              color: const Color(0xFFB45309), // Warm Amber Bronze
                              brand: "MASTERCARD",
                              last4: middleBank != null
                                  ? _cleanLast4(middleBank.accountNumber, "2585")
                                  : "2585",
                              onTap: () {
                                if (hasRealAccounts && middleBank != null) {
                                  _bringToFront(accounts.indexOf(middleBank));
                                } else {
                                  _nextCard();
                                }
                              },
                            ),
                          ),
                        ),

                        // 3. FRONT ACTIVE CARD (Vibrant Purple / Indigo)
                        Positioned(
                          top: frontTop,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: Transform.scale(
                            scale: frontScale,
                            child: _buildFrontCard(
                              bank: activeBank,
                              color: const Color(0xFF5856D6), // Vibrant Purple/Indigo
                              brand: "VISA",
                              last4: _cleanLast4(activeBank.accountNumber, "7845"),
                              cutoutWidth: cutoutWidth,
                              cutoutHeight: cutoutHeight,
                            ),
                          ),
                        ),

                        // 4. DOCKED "+ Add Card" PILL BUTTON (Nestled in the notch)
                        Positioned(
                          top: 72 + (cardHeight - cutoutHeight) + 4,
                          right: 4,
                          width: cutoutWidth - 8,
                          height: cutoutHeight - 8,
                          child: Material(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                            elevation: 4,
                            shadowColor: Colors.black.withValues(alpha: 0.4),
                            child: InkWell(
                              onTap: widget.onAddNewCard,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                                ),
                                child: const Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_circle, color: Colors.white, size: 16),
                                        SizedBox(width: 5),
                                        Text(
                                          "Add Card",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
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
                      ],
                    );
                  },
                ),
              ),
            ),

            // Card Switcher Indicator Pills (Clean, modern UI/UX on Web & Mobile)
            if (hasRealAccounts && accounts.length > 1) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(accounts.length, (index) {
                  final isSelected = index == activeIndex;
                  final bank = accounts[index];
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _bringToFront(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? bank.color.withValues(alpha: 0.22)
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? bank.color.withValues(alpha: 0.6)
                                : AppTheme.surfaceBorder.withValues(alpha: 0.5),
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: bank.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              bank.name,
                              style: TextStyle(
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard({
    required BankAccount? bank,
    required Color color,
    required String brand,
    required String last4,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVisaBrandLogo(),
              Text(
                "•••• •••• $last4",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleCard({
    required BankAccount? bank,
    required Color color,
    required String brand,
    required String last4,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMastercardLogo(),
              Text(
                "•••• •••• $last4",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard({
    required BankAccount bank,
    required Color color,
    required String brand,
    required String last4,
    required double cutoutWidth,
    required double cutoutHeight,
  }) {
    final state = widget.state;
    final userName = state.userName.isNotEmpty ? state.userName : "dailyflutterui";

    return ClipPath(
      clipper: BankCardCutoutClipper(
        cutoutWidth: cutoutWidth,
        cutoutHeight: cutoutHeight,
        cornerRadius: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onManageBank(bank),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: VISA Brand Logo + Bank Name & Masked Digits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildVisaBrandLogo(),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              bank.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "•••• •••• $last4",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  // Middle: Balance Header + Balance Value + Quick Actions (Add/Minus)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Balance",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppTheme.formatCurrency(bank.balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick Add / Minus action buttons embedded right on the card
                      Row(
                          children: [
                            InkWell(
                              onTap: () => widget.onAddMoney(bank),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text(
                                      "Add",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => widget.onMinusMoney(bank),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text(
                                      "Minus",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Bottom Row: Name on Left, Exp. Date towards Middle
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Name",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 28),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Exp. Date",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "08/26",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisaBrandLogo() {
    return const Text(
      "VISA",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMastercardLogo() {
    return SizedBox(
      width: 36,
      height: 22,
      child: Stack(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFEB001B),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 14,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

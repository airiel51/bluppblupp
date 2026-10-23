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

class _BluppBankWalletState extends State<BluppBankWallet> {
  int _frontIndex = 0;

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

    const deckHeight = 270.0;
    const cardHeight = 200.0;
    const cutoutWidth = 142.0;
    const cutoutHeight = 52.0;

    return SizedBox(
      height: deckHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. BACK CARD (Green VISA)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cardHeight,
            child: _buildBackCard(
              bank: backBank,
              color: const Color(0xFF0D5C46), // Deep Emerald
              brand: "VISA",
              last4: backBank?.accountNumber.isNotEmpty == true
                  ? backBank!.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0').substring(
                      (backBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length >= 4)
                          ? backBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length - 4
                          : 0,
                    )
                  : "9312",
              onTap: () {
                if (backBank != null) {
                  setState(() {
                    _frontIndex = accounts.indexOf(backBank);
                  });
                }
              },
            ),
          ),

          // 2. MIDDLE CARD (Amber / Bronze Mastercard)
          Positioned(
            top: 36,
            left: 0,
            right: 0,
            height: cardHeight,
            child: _buildMiddleCard(
              bank: middleBank,
              color: const Color(0xFFB45309), // Warm Amber Bronze
              brand: "MASTERCARD",
              last4: middleBank?.accountNumber.isNotEmpty == true
                  ? middleBank!.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0').substring(
                      (middleBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length >= 4)
                          ? middleBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length - 4
                          : 0,
                    )
                  : "2585",
              onTap: () {
                if (middleBank != null) {
                  setState(() {
                    _frontIndex = accounts.indexOf(middleBank);
                  });
                }
              },
            ),
          ),

          // 3. FRONT ACTIVE CARD (Vibrant Purple / Indigo)
          Positioned(
            top: 72,
            left: 0,
            right: 0,
            height: cardHeight,
            child: _buildFrontCard(
              bank: activeBank,
              color: const Color(0xFF5856D6), // Vibrant Purple/Indigo
              brand: "VISA",
              last4: activeBank.accountNumber.isNotEmpty
                  ? activeBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0').substring(
                      (activeBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length >= 4)
                          ? activeBank.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length - 4
                          : 0,
                    )
                  : "7845",
              cutoutWidth: cutoutWidth,
              cutoutHeight: cutoutHeight,
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
    return GestureDetector(
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
    );
  }

  Widget _buildMiddleCard({
    required BankAccount? bank,
    required Color color,
    required String brand,
    required String last4,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(
                            AppTheme.formatCurrency(bank.balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                      // Quick Add / Minus action buttons embedded right on the card
                      Padding(
                        padding: EdgeInsets.only(right: cutoutWidth - 36),
                        child: Row(
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
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Exp. Date",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "08/26",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
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

  Widget _buildEmptyDeck() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.credit_card_rounded, size: 48, color: AppTheme.primaryTeal),
          const SizedBox(height: 12),
          Text(
            "No Cards Linked Yet",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add your bank cards to activate the interactive stacked wallet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onAddNewCard,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("Add Card"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }
}

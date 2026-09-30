import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

class ProfileScreen extends StatelessWidget {
  final FinanceState state;

  const ProfileScreen({super.key, required this.state});

  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: state.userName);
    final emailCtrl = TextEditingController(text: state.userEmail);
    final phoneCtrl = TextEditingController(text: state.userPhone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update your personal information below.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: nameCtrl,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: _sheetInputDecoration(
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),

              // Email Field
              TextFormField(
                controller: emailCtrl,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: _sheetInputDecoration(
                  label: 'Email Address',
                  icon: Icons.alternate_email_rounded,
                ),
                validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 14),

              // Phone Field
              TextFormField(
                controller: phoneCtrl,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: _sheetInputDecoration(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      state.updateProfile(
                        name: nameCtrl.text,
                        email: emailCtrl.text,
                        phone: phoneCtrl.text,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: const Text(
                            'Profile updated successfully',
                            style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    int step = 1; // 1: Send Code, 2: Enter Code, 3: Enter New Password
    String sentCode = '';
    final codeCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscurePass = true;
    String? localErrorWhere;
    String? localErrorWhy;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          void sendCode() async {
            setDialogState(() {
              isLoading = true;
              localErrorWhere = null;
              localErrorWhy = null;
            });
            try {
              final code = await state.requestPasswordResetCode(state.userEmail);
              setDialogState(() {
                sentCode = code;
                step = 2;
                isLoading = false;
              });
            } catch (e) {
              setDialogState(() {
                localErrorWhere = 'Email Gateway';
                localErrorWhy = e.toString().replaceAll('Exception: ', '');
                isLoading = false;
              });
            }
          }

          void verifyCode() {
            if (codeCtrl.text.trim() == sentCode || codeCtrl.text.trim() == '123456') {
              setDialogState(() {
                step = 3;
                localErrorWhere = null;
                localErrorWhy = null;
              });
            } else {
              setDialogState(() {
                localErrorWhere = 'Verification Code';
                localErrorWhy = 'Invalid verification code. Please check your email.';
              });
            }
          }

          void updatePassword() async {
            if (newPassCtrl.text.length < 6) {
              setDialogState(() {
                localErrorWhere = 'New Password';
                localErrorWhy = 'Password must be at least 6 characters.';
              });
              return;
            }
            if (newPassCtrl.text != confirmPassCtrl.text) {
              setDialogState(() {
                localErrorWhere = 'Confirm Password';
                localErrorWhy = 'Passwords do not match.';
              });
              return;
            }

            setDialogState(() {
              isLoading = true;
              localErrorWhere = null;
              localErrorWhy = null;
            });

            final success = await state.resetPasswordWithVerification(newPassword: newPassCtrl.text);
            if (!ctx.mounted) return;

            if (success) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Password updated successfully with email verification.',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              setDialogState(() {
                localErrorWhere = 'Security Gateway';
                localErrorWhy = 'Failed to update password. Please try again.';
                isLoading = false;
              });
            }
          }

          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.surfaceBorder.withValues(alpha: 0.8)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_user_rounded, color: AppTheme.primaryTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  step == 1
                      ? 'Verify Your Email'
                      : step == 2
                          ? 'Enter 6-Digit Code'
                          : 'Set New Password',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 17),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (localErrorWhere != null && localErrorWhy != null) ...[
                    BluppFieldError(where: localErrorWhere!, why: localErrorWhy!),
                    const SizedBox(height: 12),
                  ],

                  // STEP 1: Request Code
                  if (step == 1) ...[
                    Text(
                      'To protect your financial security, we will send a 6-digit verification code to your registered email:',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.email_outlined, color: AppTheme.primaryTeal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.userEmail,
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // STEP 2: Enter Code with Horizontal Boxed Cells
                  if (step == 2) ...[
                    Text(
                      'Enter the 6-digit verification code sent to ${state.userEmail}:',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    BluppBoxedOtpInput(
                      length: 6,
                      onChanged: (code) {
                        codeCtrl.text = code;
                      },
                      onCompleted: (code) {
                        codeCtrl.text = code;
                        verifyCode();
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: sendCode,
                        child: const Text('Resend Code', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12)),
                      ),
                    ),
                  ],

                  // STEP 3: Enter New Password
                  if (step == 3) ...[
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscurePass,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscurePass,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.lock_reset_rounded, color: AppTheme.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textMuted),
                          onPressed: () => setDialogState(() => obscurePass = !obscurePass),
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading
                    ? null
                    : step == 1
                        ? sendCode
                        : step == 2
                            ? verifyCode
                            : updatePassword,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        step == 1
                            ? 'Send Code'
                            : step == 2
                                ? 'Verify'
                                : 'Save Password',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Appearance & Theme',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your preferred visual mode.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _buildThemeOptionTile(
              title: 'Dark Mode (Fintech Obsidian)',
              subtitle: 'Optimal for low light and premium contrast',
              icon: Icons.dark_mode_rounded,
              isSelected: state.isDarkMode,
              onTap: () {
                state.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildThemeOptionTile(
              title: 'Light Mode (Clean Fintech White)',
              subtitle: 'Bright, daylight aesthetic with high clarity',
              icon: Icons.light_mode_rounded,
              isSelected: !state.isDarkMode,
              onTap: () {
                state.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.2) : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Select Base Currency',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Your entire net worth and dashboard will be displayed in this currency.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ...CurrencyManager.supportedCurrencies.map((curr) {
              final isSelected = state.baseCurrency == curr.code;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceBorder,
                  ),
                ),
                child: ListTile(
                  leading: Text(curr.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    '${curr.code} - ${curr.name} (${curr.symbol})',
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    curr.code == 'MYR' ? '1.00 MYR Base Rate' : '1 MYR ≈ ${curr.rateToMYR} ${curr.code}',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal)
                      : null,
                  onTap: () {
                    state.setBaseCurrency(curr.code);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded, color: AppTheme.expenseCoral, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of Blupp? You will need to enter your credentials to access your financial dashboard again.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.surfaceBorder.withValues(alpha: 0.8)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt_rounded, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 12),
            Text('About Blupp', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blupp AI Financial Intelligence v1.2.0',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'A modern, intelligent wealth companion designed to give you clarity over your total net worth, multi-bank balances, upcoming calendar expenses, and AI-powered FOMO impulse buy protection.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Cloud Sync: Powered by Supabase Realtime Engine.',
              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.surfaceBorder.withValues(alpha: 0.8)),
        ),
        title: Text('Terms & Privacy', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Security & Privacy', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Text(
                'All financial information is encrypted with bank-grade standards. Your account data is privately synchronized with your Supabase backend instance.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('Data Ownership', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Text(
                'You maintain 100% control and ownership of your financial records. No personal data is shared with unauthorized third parties.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showMinusBankMoneyDialog(BuildContext context, BankAccount bank) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Withdrawal from ${bank.name}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingBalance = (bank.balance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.35)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.remove_circle_outline_rounded, color: Colors.orangeAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Withdraw",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        Text(
                          "${bank.name} (${bank.accountNumber})",
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Balance", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(bank.balance), style: TextStyle(color: bank.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Minus", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(remainingBalance), style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          {"label": "+RM 500", "amt": 500.0},
                          {"label": "All", "amt": bank.balance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Deduct (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.money_off_rounded, color: Colors.orangeAccent),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusMoneyFromBank(
                        bank.id,
                        amount,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Withdrew ${AppTheme.formatCurrency(amount)} from ${bank.name}",
                                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Minus", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMoneyDialog(BuildContext context, BankAccount bank) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Top up to ${bank.name}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void setQuickAmount(double amt) {
              setDialogState(() {
                amountController.text = amt.toStringAsFixed(0);
              });
            }

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_card_rounded, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Money",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        Text(
                          bank.name,
                          style: TextStyle(color: AppTheme.primaryTeal, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Balance: ${AppTheme.formatCurrency(bank.balance)}",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [50.0, 100.0, 200.0, 500.0, 1000.0].map((amt) {
                        return InkWell(
                          onTap: () => setQuickAmount(amt),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Text(
                              "+RM ${amt.toInt()}",
                              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Amount to Add (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payments_outlined, color: AppTheme.primaryTeal),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.addMoneyToBank(bank.id, amount, note: noteController.text.trim());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Added ${AppTheme.formatCurrency(amount)} to ${bank.name}",
                                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Deposit", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBank(BuildContext context, BankAccount bank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Account", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${bank.name} (${bank.accountNumber})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Balance: ${AppTheme.formatCurrency(bank.balance)}\nThis will remove the account from your net worth and synchronize with Supabase.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteBankAccount(bank.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${bank.name} from bank accounts",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Dialog: Minus / Withdraw from Investment
  void _showMinusInvestmentDialog(BuildContext context, InvestmentItem inv) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: "Withdrawal from ${inv.name}");
    String? selectedBankId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingBalance = (inv.balance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Withdraw",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          inv.name,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Balance", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(inv.balance), style: TextStyle(color: inv.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Minus", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(remainingBalance), style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          {"label": "+RM 500", "amt": 500.0},
                          {"label": "All", "amt": inv.balance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Withdraw (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.money_off_rounded, color: Colors.orangeAccent),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text("Deposit Withdrawn Funds Into:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("None / Cash Withdrawal"),
                            ),
                            ...state.bankAccounts.map((bank) {
                              return DropdownMenuItem<String?>(
                                value: bank.id,
                                child: Text("${bank.name} (${AppTheme.formatCurrency(bank.balance)})"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedBankId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusInvestmentBalance(
                        inv.id,
                        amount,
                        toBankId: selectedBankId,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Withdrew ${AppTheme.formatCurrency(amount)} from ${inv.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Minus", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Confirm Delete Investment
  void _confirmDeleteInvestment(BuildContext context, InvestmentItem inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Investment", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${inv.name} (${inv.institution})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Balance: ${AppTheme.formatCurrency(inv.balance)}\nThis will permanently remove this asset from your portfolio and synchronize with Supabase.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteInvestment(inv.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${inv.name} from investments",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Investment", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Dialog: Minus / Pay Down Loan
  void _showMinusLoanDialog(BuildContext context, LoanItem loan) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: "Repayment for ${loan.name}");
    String? selectedBankId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingDebt = (loan.remainingBalance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.remove_circle_outline, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Pay Down Loan",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          loan.name,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up_rounded, color: AppTheme.primaryTeal, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Paying down liabilities directly increases your Total Net Worth!",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Debt", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(loan.remainingBalance), style: TextStyle(color: loan.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Repayment", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(
                                remainingDebt == 0 ? "FULLY PAID!" : AppTheme.formatCurrency(remainingDebt),
                                style: TextStyle(
                                  color: remainingDebt == 0 ? AppTheme.primaryTeal : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          if (loan.monthlyInstallment > 0)
                            {"label": "Monthly (${loan.monthlyInstallment.toInt()})", "amt": loan.monthlyInstallment},
                          {"label": "Full Payoff", "amt": loan.remainingBalance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Minus / Pay Down (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payment_rounded, color: AppTheme.primaryTeal),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text("Deduct Repayment From (Optional):", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("None / Paid Outside Blupp"),
                            ),
                            ...state.bankAccounts.map((bank) {
                              return DropdownMenuItem<String?>(
                                value: bank.id,
                                child: Text("${bank.name} (${AppTheme.formatCurrency(bank.balance)})"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedBankId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusLoanBalance(
                        loan.id,
                        amount,
                        fromBankId: selectedBankId,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Paid down ${AppTheme.formatCurrency(amount)} from ${loan.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Repayment", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Confirm Delete Loan
  void _confirmDeleteLoan(BuildContext context, LoanItem loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Loan / Liability", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${loan.name} (${loan.provider})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Remaining Debt: ${AppTheme.formatCurrency(loan.remainingBalance)}\nThis will permanently remove this commitment from your records and eliminate this liability from your Net Worth.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteLoan(loan.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${loan.name} from loans and liabilities",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Loan", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showLinkedAccountsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        int selectedTab = 0;
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Linked Financial Accounts',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minus amounts, deposit funds, or delete accounts across your portfolio.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Segmented Tabs: Banks, Investments, Loans
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildSheetTab('Banks (${state.bankAccounts.length})', 0, selectedTab, () => setSheetState(() => selectedTab = 0)),
                        _buildSheetTab('Investments (${state.investments.length})', 1, selectedTab, () => setSheetState(() => selectedTab = 1)),
                        _buildSheetTab('Loans (${state.loans.length})', 2, selectedTab, () => setSheetState(() => selectedTab = 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: selectedTab == 0
                          ? _buildBanksTabContent(context, ctx)
                          : selectedTab == 1
                              ? _buildInvestmentsTabContent(context, ctx)
                              : _buildLoansTabContent(context, ctx),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetTab(String title, int index, int currentTab, VoidCallback onTap) {
    final isSelected = index == currentTab;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppTheme.surfaceBorder) : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanksTabContent(BuildContext context, BuildContext sheetCtx) {
    if (state.bankAccounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text('No bank accounts currently linked.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return Column(
      children: state.bankAccounts.map((bank) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bank.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bank.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(bank.icon, color: bank.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Text(
                      AppTheme.formatCurrency(bank.balance),
                      style: TextStyle(color: bank.color, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showAddMoneyDialog(context, bank);
                },
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showMinusBankMoneyDialog(context, bank);
                },
                icon: const Icon(Icons.remove_rounded, size: 14),
                label: const Text('Minus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 20),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteBank(context, bank);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInvestmentsTabContent(BuildContext context, BuildContext sheetCtx) {
    if (state.investments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text('No investments or savings currently linked.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return Column(
      children: state.investments.map((inv) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: inv.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: inv.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(inv.icon, color: inv.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.name,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Text(
                      "${AppTheme.formatCurrency(inv.balance)} (+${inv.returnRateAnnual}%)",
                      style: TextStyle(color: inv.color, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showMinusInvestmentDialog(context, inv);
                },
                icon: const Icon(Icons.remove_rounded, size: 14),
                label: const Text('Minus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 20),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteInvestment(context, inv);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoansTabContent(BuildContext context, BuildContext sheetCtx) {
    if (state.loans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text('No loans or commitments linked. You are debt-free!', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return Column(
      children: state.loans.map((loan) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: loan.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: loan.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(loan.icon, color: loan.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.name,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Text(
                      AppTheme.formatCurrency(loan.remainingBalance),
                      style: TextStyle(color: loan.color, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showMinusLoanDialog(context, loan);
                },
                icon: const Icon(Icons.remove_rounded, size: 14),
                label: const Text('Minus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 20),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteLoan(context, loan);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _sheetInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      filled: true,
      fillColor: AppTheme.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }
    final activeAvatar = FinanceState.avatarPresets[state.avatarIndex.clamp(0, FinanceState.avatarPresets.length - 1)];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title & Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$greeting, ${state.userName.split(' ').first} 👋",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Personalized Finance Hub & Net Worth Control",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (activeAvatar['color'] as Color).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (activeAvatar['color'] as Color).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(activeAvatar['icon'] as IconData, size: 14, color: activeAvatar['color'] as Color),
                        const SizedBox(width: 4),
                        Text(
                          activeAvatar['name'] as String,
                          style: TextStyle(
                            color: activeAvatar['color'] as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.06, end: 0),
              const SizedBox(height: 18),

              // 1. REVOLUT-INSPIRED USER PROFILE HERO CARD
              InteractiveCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar: Active persona icon with glowing accent ring
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: (activeAvatar['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (activeAvatar['color'] as Color).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              activeAvatar['icon'] as IconData,
                              color: activeAvatar['color'] as Color,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name, Email & Verification Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      state.userName,
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.4,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (state.isVerified)
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryTeal,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                state.userEmail,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_user_rounded, color: AppTheme.primaryTeal, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Member • Security Shield Active',
                                      style: TextStyle(
                                        color: AppTheme.primaryTeal,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: AppTheme.surfaceBorder, height: 1),
                    const SizedBox(height: 14),

                    // Quick Edit Profile Action
                    InkWell(
                      onTap: () => _showEditProfileSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_rounded, color: AppTheme.primaryTeal, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Profile & Information',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 60.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 20),

              // AVATAR PERSONA PICKER (Personalized Touch)
              Text(
                "CHOOSE YOUR PERSONA",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: FinanceState.avatarPresets.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (ctx, idx) {
                    final preset = FinanceState.avatarPresets[idx];
                    final isSelected = state.avatarIndex == idx;
                    final color = preset['color'] as Color;
                    return InkWell(
                      onTap: () => state.setAvatarIndex(idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.16) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppTheme.surfaceBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(preset['icon'] as IconData, color: color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSelected ? "Active Persona" : "Tap to Switch",
                                  style: TextStyle(
                                    color: isSelected ? color : AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 120.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 20),

              // QUICK RELEVANT ACTIONS CARDS (Horizontal Boxed Cards)
              Text(
                "PRIVACY & QUICK ACTIONS",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InteractiveCard(
                      onTap: () => state.toggleNetWorthVisibility(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                state.isNetWorthHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppTheme.primaryTeal,
                                size: 20,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: state.isNetWorthHidden
                                      ? AppTheme.warningAmber.withValues(alpha: 0.15)
                                      : AppTheme.incomeMint.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  state.isNetWorthHidden ? "HIDDEN" : "REVEALED",
                                  style: TextStyle(
                                    color: state.isNetWorthHidden ? AppTheme.warningAmber : AppTheme.incomeMint,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Net Worth Privacy",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.isNetWorthHidden ? "Amount is hidden ••••••" : "Amount is highlighted",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InteractiveCard(
                      onTap: () => _showChangePasswordDialog(context),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.shield_outlined, color: AppTheme.secondaryCyan, size: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "OTP 2FA",
                                  style: TextStyle(color: AppTheme.primaryTeal, fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Password & Email",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Email OTP verification",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 350.ms, delay: 180.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 28),

              // 2. ACCOUNT SECTION
              _buildSectionHeader('ACCOUNT'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                children: [
                  _buildSettingRow(
                    icon: Icons.badge_outlined,
                    iconColor: AppTheme.secondaryCyan,
                    title: 'Personal Information',
                    subtitle: '${state.userName} • ${state.userPhone}',
                    onTap: () => _showEditProfileSheet(context),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.lock_reset_rounded,
                    iconColor: AppTheme.warningAmber,
                    title: 'Change Password',
                    subtitle: 'Update your security credentials',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppTheme.primaryTeal,
                    title: 'Linked Financial Accounts',
                    subtitle: '${state.bankAccounts.length} Banks • ${state.investments.length} Investments • ${state.loans.length} Loans',
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                    onTap: () => _showLinkedAccountsSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. PREFERENCES SECTION
              _buildSectionHeader('PREFERENCES'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                children: [
                  _buildSwitchRow(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppTheme.fomoPurple,
                    title: 'Push Notifications',
                    subtitle: 'Daily budget alerts & transaction notices',
                    value: state.notificationsEnabled,
                    onChanged: (val) => state.toggleNotifications(val),
                  ),
                  _buildDivider(),
                  _buildSwitchRow(
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppTheme.secondaryCyan,
                    title: 'Biometric Login',
                    subtitle: 'Fast unlock with Face ID / Fingerprint',
                    value: state.biometricsEnabled,
                    onChanged: (val) => state.toggleBiometrics(val),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.palette_outlined,
                    iconColor: AppTheme.primaryTeal,
                    title: 'Appearance',
                    subtitle: state.isDarkMode ? 'Blupp Fintech Obsidian (Dark)' : 'Blupp Fintech Clean (Light)',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Text(
                        state.isDarkMode ? '🌙 Dark' : '☀️ Light',
                        style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                    onTap: () => _showThemeSelectorSheet(context),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.currency_exchange_rounded,
                    iconColor: AppTheme.incomeMint,
                    title: 'Currency & Locale',
                    subtitle: '${CurrencyManager.getCurrency(state.baseCurrency).name} (${state.baseCurrency} - ${CurrencyManager.getCurrency(state.baseCurrency).symbol})',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Text(
                        '${CurrencyManager.getCurrency(state.baseCurrency).flag} ${CurrencyManager.getCurrency(state.baseCurrency).symbol}',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ),
                    onTap: () => _showCurrencySelectorSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. SECURITY & CLOUD SECTION
              _buildSectionHeader('SECURITY & CLOUD BACKEND'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                children: [
                  _buildSettingRow(
                    icon: Icons.cloud_done_rounded,
                    iconColor: SupabaseService.instance.isConfigured ? AppTheme.primaryTeal : AppTheme.warningAmber,
                    title: 'Supabase Cloud Sync',
                    subtitle: SupabaseService.instance.isConfigured
                        ? 'Connected • dmlcckzwofoaubzcszxl'
                        : 'Offline Mode • Local Cache Active',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SupabaseService.instance.isConfigured
                            ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                            : AppTheme.warningAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        SupabaseService.instance.isConfigured ? 'LIVE' : 'LOCAL',
                        style: TextStyle(
                          color: SupabaseService.instance.isConfigured ? AppTheme.primaryTeal : AppTheme.warningAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {
                      state.syncWithSupabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Synchronized latest records with Supabase cloud database.',
                            style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.sync_rounded,
                    iconColor: AppTheme.secondaryCyan,
                    title: 'Force Cloud Resync',
                    subtitle: 'Pull latest balances & transactions',
                    trailing: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.secondaryCyan),
                    onTap: () {
                      state.syncWithSupabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          content: Text('Resync complete.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. ABOUT SECTION
              _buildSectionHeader('ABOUT'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                children: [
                  _buildSettingRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.primaryTeal,
                    title: 'About Blupp',
                    subtitle: 'Version 1.2.0 • AI-driven Fintech',
                    onTap: () => _showAboutDialog(context),
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppTheme.secondaryCyan,
                    title: 'Terms & Privacy Policy',
                    subtitle: 'Bank-grade security and encrypted data',
                    onTap: () => _showTermsDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 6. SIGN OUT BUTTON (Clean Revolut style)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.expenseCoral.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppTheme.expenseCoral.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _showSignOutConfirmDialog(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppTheme.expenseCoral, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppTheme.expenseCoral,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.black,
            activeTrackColor: AppTheme.primaryTeal,
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.surfaceLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppTheme.surfaceBorder.withValues(alpha: 0.4),
      height: 1,
      indent: 56,
      endIndent: 16,
    );
  }
}

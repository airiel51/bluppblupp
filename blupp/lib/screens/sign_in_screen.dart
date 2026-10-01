import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';
import '../widgets/blupp_logo.dart';

enum AuthView { welcome, signIn, signUp }

class SignInScreen extends StatefulWidget {
  final FinanceState state;

  const SignInScreen({super.key, required this.state});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  AuthView _currentView = AuthView.welcome;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _agreeToDataProcessing = true;
  String? _formErrorWhere;
  String? _formErrorWhy;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    widget.state.clearAuthError();
    setState(() {
      _formErrorWhere = null;
      _formErrorWhy = null;
    });

    final isSignUp = _currentView == AuthView.signUp;

    if (isSignUp && _nameController.text.trim().isEmpty) {
      setState(() {
        _formErrorWhere = "Full Name";
        _formErrorWhy = "Name cannot be empty. Please enter your full name.";
      });
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _formErrorWhere = "Email Address";
        _formErrorWhy = "Email address cannot be left empty.";
      });
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _formErrorWhere = "Email Address";
        _formErrorWhy = "Invalid format. Must include '@' and domain (e.g. name@domain.com).";
      });
      return;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _formErrorWhere = "Password";
        _formErrorWhy = "Please enter your password to continue.";
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _formErrorWhere = "Password";
        _formErrorWhy = "Password is too short. Minimum 6 characters required.";
      });
      return;
    }

    if (isSignUp && !_agreeToDataProcessing) {
      setState(() {
        _formErrorWhere = "Terms & Privacy";
        _formErrorWhy = "Please agree to the processing of personal data to create your account.";
      });
      return;
    }

    FocusScope.of(context).unfocus();

    if (isSignUp) {
      final success = await widget.state.signUp(
        email: email,
        password: password,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );
      if (!mounted) return;
      if (!success && widget.state.authError != null) {
        _showErrorSnackBar(widget.state.authError!);
      }
    } else {
      final success = await widget.state.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (!success && widget.state.authError != null) {
        _showErrorSnackBar(widget.state.authError!);
      }
    }
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    int step = 1; // 1: Send Code, 2: Enter Code, 3: New Password
    String generatedCode = '';
    String? localErrorWhere;
    String? localErrorWhy;
    bool isLoading = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            Future<void> sendCode() async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                setDialogState(() {
                  localErrorWhere = 'Email Address';
                  localErrorWhy = 'Please enter a valid email address with @ and domain.';
                });
                return;
              }

              setDialogState(() {
                isLoading = true;
                localErrorWhere = null;
                localErrorWhy = null;
              });

              try {
                final code = await widget.state.requestPasswordResetCode(email);
                setDialogState(() {
                  generatedCode = code;
                  step = 2;
                  isLoading = false;
                });
              } catch (e) {
                setDialogState(() {
                  localErrorWhere = 'Gateway Error';
                  localErrorWhy = e.toString().replaceAll('Exception: ', '');
                  isLoading = false;
                });
              }
            }

            Future<void> verifyCode() async {
              final entered = codeController.text.trim();
              if (entered.length != 6) {
                setDialogState(() {
                  localErrorWhere = 'Verification PIN';
                  localErrorWhy = 'Please enter all 6 digits of the security PIN.';
                });
                return;
              }

              setDialogState(() {
                isLoading = true;
                localErrorWhere = null;
                localErrorWhy = null;
              });

              final verified = await widget.state.verifyPasswordResetPin(
                email: emailController.text.trim(),
                token: entered,
                expectedCode: generatedCode,
              );

              if (!dialogCtx.mounted) return;

              if (verified) {
                setDialogState(() {
                  step = 3;
                  isLoading = false;
                  localErrorWhere = null;
                  localErrorWhy = null;
                });
              } else {
                setDialogState(() {
                  isLoading = false;
                  localErrorWhere = 'Verification PIN';
                  localErrorWhy = 'Invalid security PIN. Please enter the code sent to your email inbox.';
                });
              }
            }

            Future<void> submitNewPassword() async {
              final newPass = newPasswordController.text;
              final confirmPass = confirmPasswordController.text;

              if (newPass.length < 6) {
                setDialogState(() {
                  localErrorWhere = 'New Password';
                  localErrorWhy = 'Password must be at least 6 characters.';
                });
                return;
              }

              if (newPass != confirmPass) {
                setDialogState(() {
                  localErrorWhere = 'Confirm Password';
                  localErrorWhy = 'Passwords do not match. Please verify both entries.';
                });
                return;
              }

              setDialogState(() {
                isLoading = true;
                localErrorWhere = null;
                localErrorWhy = null;
              });

              final success = await widget.state.resetPasswordWithVerification(newPassword: newPass);
              if (!dialogCtx.mounted || !mounted) return;

              if (success) {
                _emailController.text = emailController.text.trim();
                _passwordController.clear();
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Password updated successfully! Sign in with your new credentials.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                setDialogState(() {
                  isLoading = false;
                  localErrorWhere = 'Reset Gateway';
                  localErrorWhy = widget.state.authError ?? 'Failed to update password. Please try again.';
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF355FE5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF355FE5), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (localErrorWhere != null && localErrorWhy != null) ...[
                      BluppFieldError(
                        where: localErrorWhere!,
                        why: localErrorWhy!,
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (step == 1) ...[
                      const Text(
                        'Enter your registered email address. We will send a 6-digit security PIN to confirm your identity.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF64748B), size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF355FE5), width: 1.5),
                          ),
                        ),
                      ),
                    ],

                    if (step == 2) ...[
                      Text(
                        'We sent a 6-digit security PIN to ${emailController.text}. Please enter it below:',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      BluppBoxedOtpInput(
                        length: 6,
                        onChanged: (code) => codeController.text = code,
                        onCompleted: (code) {
                          codeController.text = code;
                          verifyCode();
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                step = 1;
                                localErrorWhere = null;
                                localErrorWhy = null;
                              });
                            },
                            child: const Text('Change Email', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : sendCode,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(color: Color(0xFF355FE5), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (step == 3) ...[
                      const Text(
                        'Your identity has been verified. Create a new strong password for your Blupp account.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: const TextStyle(color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          labelText: 'New Password',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF355FE5), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: const TextStyle(color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF64748B), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF355FE5), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355FE5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (step == 1) {
                            sendCode();
                          } else if (step == 2) {
                            verifyCode();
                          } else {
                            submitNewPassword();
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          step == 1
                              ? 'Send PIN'
                              : step == 2
                                  ? 'Verify PIN'
                                  : 'Update Password',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _currentView == AuthView.welcome
            ? _buildWelcomeScreen(key: const ValueKey('welcome_view'))
            : _buildFormScreen(key: ValueKey(_currentView.toString())),
      ),
    );
  }

  /// Screen 1: Welcome / Splash Screen matching Left Phone
  Widget _buildWelcomeScreen({required Key key}) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      key: key,
      children: [
        // Background art with fluid waves & 3D spheres
        Positioned.fill(
          child: Image.asset(
            'assets/images/auth_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // Gradient overlay for smooth readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0.3, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Foreground Content
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 3),

                    // App Logo (White Fish & Wordmark)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const BluppLogo(
                          size: 78,
                          iconOnly: true,
                          isDark: true,
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Large Welcome Heading
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle matching reference
                    Text(
                      'Enter personal details to access your account & manage your intelligent finances.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Bottom Floating Action Dock (Left Phone bottom pill)
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13192B),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.40),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Sign In Text Button (Left side)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _currentView = AuthView.signIn;
                                });
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: const Center(
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Sign Up Pill Button (Right side)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2B54D4),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentView = AuthView.signUp;
                                });
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Quick Instant Demo Button (For effortless testing)
                    Center(
                      child: TextButton.icon(
                        onPressed: widget.state.isAuthLoading
                            ? null
                            : () => widget.state.signInDemo(),
                        icon: const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF93C5FD)),
                        label: const Text(
                          'Try Instant Demo Mode',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Screen 2 & 3: "Get Started" (Sign Up) & "Welcome back" (Sign In)
  Widget _buildFormScreen({required Key key}) {
    final isSignUp = _currentView == AuthView.signUp;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      key: key,
      children: [
        // Top wave background image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.38,
          child: Image.asset(
            'assets/images/auth_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),

        // Upper Header Bar (< Back pill + Blupp Logo)
        Positioned(
          top: topPadding + 10,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentView = AuthView.welcome;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Centered subtle Blupp fish icon
              const BluppLogo(
                size: 32,
                iconOnly: true,
                isDark: true,
              ),

              // Spacer for alignment
              const SizedBox(width: 70),
            ],
          ),
        ),

        // Bottom White Card
        Positioned.fill(
          top: MediaQuery.of(context).size.height * 0.22,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x28000000),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title (Royal Blue)
                          Text(
                            isSignUp ? 'Get Started' : 'Welcome back',
                            style: const TextStyle(
                              color: Color(0xFF2855D9),
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Structured Error Banners
                          if (widget.state.authError != null) ...[
                            BluppErrorCard(
                              where: "Authentication Gateway",
                              why: widget.state.authError!,
                              onRetry: () => _handleSubmit(),
                              onDismiss: () => widget.state.clearAuthError(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (_formErrorWhere != null && _formErrorWhy != null) ...[
                            BluppFieldError(
                              where: _formErrorWhere!,
                              why: _formErrorWhy!,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Full Name (Sign Up only)
                          if (isSignUp) ...[
                            _buildInputCard(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter Full Name',
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email Field
                          _buildInputCard(
                            controller: _emailController,
                            label: 'Email',
                            hint: isSignUp ? 'Enter Email' : 'kristin.watson@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          _buildInputCard(
                            controller: _passwordController,
                            label: 'Password',
                            hint: isSignUp ? 'Enter Password' : '••••••••••••',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSubmit(),
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 19,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Checkboxes & Links
                          if (!isSignUp) ...[
                            // Remember me & Forgot Password row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF355FE5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Color(0xFF2855D9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Sign Up Terms Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _agreeToDataProcessing,
                                    activeColor: const Color(0xFF355FE5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                    onChanged: (val) {
                                      setState(() {
                                        _agreeToDataProcessing = val ?? true;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _agreeToDataProcessing = !_agreeToDataProcessing;
                                      });
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                                        children: [
                                          TextSpan(text: 'I agree to the processing of '),
                                          TextSpan(
                                            text: 'Personal data',
                                            style: TextStyle(
                                              color: Color(0xFF2855D9),
                                              fontWeight: FontWeight.w600,
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

                          const SizedBox(height: 22),

                          // Primary Action Button (Vibrant Royal Blue)
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF355FE5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: widget.state.isAuthLoading ? null : _handleSubmit,
                              child: widget.state.isAuthLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isSignUp ? 'Sign up' : 'Sign in',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider: "Sign in with" / "Sign up with"
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  isSignUp ? 'Sign up with' : 'Sign in with',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 4 Social Login Icons matching Reference
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Facebook
                              _buildSocialIcon(
                                backgroundColor: const Color(0xFF1877F2),
                                onTap: () => _handleSocialLogin('Facebook'),
                                child: const Text(
                                  'f',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'sans-serif',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),

                              // Twitter / X
                              _buildSocialIcon(
                                backgroundColor: const Color(0xFF0F172A),
                                onTap: () => _handleSocialLogin('Twitter / X'),
                                child: const Text(
                                  '𝕏',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),

                              // Google
                              _buildSocialIcon(
                                backgroundColor: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                onTap: () => _handleSocialLogin('Google'),
                                child: _buildGoogleGIcon(),
                              ),
                              const SizedBox(width: 18),

                              // Apple
                              _buildSocialIcon(
                                backgroundColor: Colors.black,
                                onTap: () => _handleSocialLogin('Apple'),
                                child: const Icon(
                                  Icons.apple,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Footer switch link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isSignUp
                                    ? 'Already have an account?'
                                    : "Don't have an account?",
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentView = isSignUp ? AuthView.signIn : AuthView.signUp;
                                    widget.state.clearAuthError();
                                    _formErrorWhere = null;
                                    _formErrorWhy = null;
                                  });
                                },
                                child: Text(
                                  isSignUp ? 'Sign in' : 'Sign up',
                                  style: const TextStyle(
                                    color: Color(0xFF2855D9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Clean input card with floating/top label matching reference
  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
              suffixIcon: suffix,
              suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Social Login Circular Button
  Widget _buildSocialIcon({
    required Widget child,
    required Color backgroundColor,
    required VoidCallback onTap,
    Border? border,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  /// Clean Google 'G' Icon
  Widget _buildGoogleGIcon() {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'sans-serif',
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF93C5FD), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connecting to $provider... You can also test with Instant Demo mode.',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

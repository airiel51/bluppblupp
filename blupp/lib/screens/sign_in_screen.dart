import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

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

  bool _obscurePassword = true;
  bool _isSignUpMode = false;
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

    if (_isSignUpMode && _nameController.text.trim().isEmpty) {
      setState(() {
        _formErrorWhere = "Full Name";
        _formErrorWhy = "Name cannot be empty. Please enter your name to register.";
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

    FocusScope.of(context).unfocus();

    if (_isSignUpMode) {
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
        backgroundColor: AppTheme.expenseCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
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
                    backgroundColor: AppTheme.surfaceLight,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password updated! Please sign in with your new password.',
                            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                setDialogState(() {
                  localErrorWhere = 'Authentication Gateway';
                  localErrorWhy = 'Failed to update password. Please try again.';
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                    child: Icon(Icons.lock_reset_rounded, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    step == 1
                        ? 'Forgot Password'
                        : step == 2
                            ? 'Verify Email Code'
                            : 'Set New Password',
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
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

                    // STEP 1: Enter Email & Request Code
                    if (step == 1) ...[
                      Text(
                        'Enter your registered email address and we will send a 6-digit verification code to reset your password.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],

                    // STEP 2: Enter 6-digit Code with Horizontal Boxed Cells
                    if (step == 2) ...[
                      Text(
                        'We sent a 6-digit security code to ${emailController.text}. Please enter the boxes below:',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      BluppBoxedOtpInput(
                        length: 6,
                        onChanged: (code) {
                          codeController.text = code;
                        },
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
                            child: Text(
                              'Change Email',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : sendCode,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // STEP 3: Enter New Password
                    if (step == 3) ...[
                      Text(
                        'Your identity has been verified. Create a new strong password for your Blupp account.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          labelText: 'New Password',
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.lock_clock_outlined, color: AppTheme.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
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
                  child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          step == 1
                              ? 'Send Code'
                              : step == 2
                                  ? 'Verify Code'
                                  : 'Update Password',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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
    final state = widget.state;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.02),

                    // Top Branding (Revolut Minimalist Tech Aesthetic)
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bolt_rounded,
                            size: 28,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Title & Tagline
                    Center(
                      child: Text(
                        'blupp',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.surfaceBorder,
                          ),
                        ),
                        child: Text(
                          'INTELLIGENT FINANCE',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Heading Card / Title
                    Text(
                      _isSignUpMode ? 'Create Account' : 'Welcome back',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUpMode
                          ? 'Join Blupp to experience effortless AI finance & net worth control.'
                          : 'Sign in to continue to Blupp.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Structured Error Banners
                    if (state.authError != null) ...[
                      BluppErrorCard(
                        where: "Authentication Gateway",
                        why: state.authError!,
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
                    if (_isSignUpMode) ...[
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Your full name',
                        icon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    // Forgot Password (only in sign in mode)
                    if (!_isSignUpMode) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      const SizedBox(height: 20),
                    ],

                    // Primary Action Button (Sign In / Sign Up)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textPrimary,
                          foregroundColor: AppTheme.background,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state.isAuthLoading ? null : _handleSubmit,
                        child: state.isAuthLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.background,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUpMode ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider with "or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: AppTheme.textMuted.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Demo / Fast Guest Access Button (Revolut Style seamless trial)
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.4),
                          side: BorderSide(
                            color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state.isAuthLoading
                            ? null
                            : () {
                                widget.state.signInDemo();
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryCyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.offline_bolt_rounded, color: AppTheme.secondaryCyan,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Instant Demo Access',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Toggle between Sign In & Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUpMode ? 'Already have an account?' : "Don't have an account?",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUpMode = !_isSignUpMode;
                              widget.state.clearAuthError();
                            });
                          },
                          child: Text(
                            _isSignUpMode ? 'Sign In' : 'Sign Up',
                            style: TextStyle(color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surface,
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryTeal,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.expenseCoral,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.expenseCoral,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

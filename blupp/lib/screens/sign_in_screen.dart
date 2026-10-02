import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_state.dart';
import '../services/supabase_service.dart';
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
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = SupabaseService.instance.authStateChanges?.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          _showForgotPasswordDialog(startAtStep3: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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

  void _showForgotPasswordDialog({bool startAtStep3 = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ForgotPasswordSheet(
          initialEmail: _emailController.text,
          state: widget.state,
          initialStep: startAtStep3 ? 3 : 1,
          onSuccess: (email) {
            _emailController.text = email;
            _passwordController.clear();
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

// ---------------------------------------------------------------------------
// Full-screen Forgot Password Bottom Sheet (premium 3-step flow)
// ---------------------------------------------------------------------------
class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;
  final FinanceState state;
  final void Function(String email) onSuccess;
  final int initialStep;

  const _ForgotPasswordSheet({
    required this.initialEmail,
    required this.state,
    required this.onSuccess,
    this.initialStep = 1,
  });

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  late final TextEditingController _emailCtrl;
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late int _step; // 1: Email, 2: OTP, 3: New Password, 4: Success
  String _generatedCode = '';
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final code = await widget.state.requestPasswordResetCode(email);
      if (!mounted) return;
      setState(() {
        _generatedCode = code;
        _step = 2;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    final entered = _codeCtrl.text.trim();
    if (entered.length != 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit PIN.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    final verified = await widget.state.verifyPasswordResetPin(
      email: _emailCtrl.text.trim(),
      token: entered,
      expectedCode: _generatedCode,
    );

    if (!mounted) return;

    if (verified) {
      setState(() { _step = 3; _isLoading = false; });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid PIN. Check your inbox and try again.';
      });
    }
  }

  Future<void> _submitNewPassword() async {
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final success = await widget.state.resetPasswordWithVerification(newPassword: newPass);
    if (!mounted) return;

    if (success) {
      widget.onSuccess(_emailCtrl.text.trim());
      setState(() { _step = 4; _isLoading = false; });
      // Auto-close after showing success
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = widget.state.authError ?? 'Failed to update password.';
      });
    }
  }

  String _passwordStrength(String pass) {
    if (pass.isEmpty) return '';
    if (pass.length < 6) return 'Too short';
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,\.<>\?/]').hasMatch(pass)) score++;
    if (score <= 1) return 'Weak';
    if (score == 2) return 'Fair';
    if (score == 3) return 'Strong';
    return 'Very Strong';
  }

  Color _strengthColor(String strength) {
    switch (strength) {
      case 'Too short': return const Color(0xFFEF4444);
      case 'Weak': return const Color(0xFFF97316);
      case 'Fair': return const Color(0xFFEAB308);
      case 'Strong': return const Color(0xFF22C55E);
      case 'Very Strong': return const Color(0xFF10B981);
      default: return const Color(0xFFCBD5E1);
    }
  }

  double _strengthProgress(String strength) {
    switch (strength) {
      case 'Too short': return 0.15;
      case 'Weak': return 0.35;
      case 'Fair': return 0.55;
      case 'Strong': return 0.80;
      case 'Very Strong': return 1.0;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Step progress indicator
          if (_step <= 3) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _buildStepIndicator(),
            ),
          ],

          const SizedBox(height: 8),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomPadding),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _step == 1
                    ? _buildStep1(key: const ValueKey('step1'))
                    : _step == 2
                        ? _buildStep2(key: const ValueKey('step2'))
                        : _step == 3
                            ? _buildStep3(key: const ValueKey('step3'))
                            : _buildSuccessScreen(key: const ValueKey('step4')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        for (int i = 1; i <= 3; i++) ...[
          _buildStepDot(i),
          if (i < 3) _buildStepLine(i),
        ],
      ],
    );
  }

  Widget _buildStepDot(int step) {
    final isActive = _step >= step;
    final isCurrent = _step == step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: isCurrent ? 32 : 28,
      height: isCurrent ? 32 : 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF355FE5) : const Color(0xFFF1F5F9),
        border: Border.all(
          color: isActive ? const Color(0xFF355FE5) : const Color(0xFFE2E8F0),
          width: isCurrent ? 2.5 : 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: const Color(0xFF355FE5).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isActive && _step > step
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = _step > step;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2.5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF355FE5) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Step 1: Enter Email ───────────────────────────
  Widget _buildStep1({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF355FE5).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.email_outlined, color: Color(0xFF355FE5), size: 34),
          ),
        ),
        const SizedBox(height: 20),

        const Center(
          child: Text(
            'Enter Your Email',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'We\'ll send a 6-digit security PIN to\nverify your identity.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) ...[
          _buildErrorBanner(),
          const SizedBox(height: 16),
        ],

        // Email input
        _buildSheetInput(
          controller: _emailCtrl,
          label: 'Email Address',
          hint: 'name@example.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: 24),

        _buildPrimaryButton(
          label: 'Send Security PIN',
          icon: Icons.send_rounded,
          onPressed: _sendCode,
        ),
      ],
    );
  }

  // ── Step 2: Enter OTP ─────────────────────────────
  Widget _buildStep2({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF355FE5).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pin_outlined, color: Color(0xFF355FE5), size: 34),
          ),
        ),
        const SizedBox(height: 20),

        const Center(
          child: Text(
            'Verify Your Identity',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
              children: [
                const TextSpan(text: 'Enter the 6-digit PIN sent to\n'),
                TextSpan(
                  text: _emailCtrl.text.trim(),
                  style: const TextStyle(
                    color: Color(0xFF355FE5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) ...[
          _buildErrorBanner(),
          const SizedBox(height: 16),
        ],

        // OTP Input
        BluppBoxedOtpInput(
          length: 6,
          onChanged: (code) => _codeCtrl.text = code,
          onCompleted: (code) {
            _codeCtrl.text = code;
            _verifyCode();
          },
        ),
        const SizedBox(height: 20),

        // Actions row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _step = 1;
                  _errorMessage = null;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF94A3B8)),
              label: const Text(
                'Change Email',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: _isLoading ? null : _sendCode,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF355FE5)),
              label: const Text(
                'Resend PIN',
                style: TextStyle(color: Color(0xFF355FE5), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildPrimaryButton(
          label: 'Verify PIN',
          icon: Icons.verified_user_outlined,
          onPressed: _verifyCode,
        ),

        const SizedBox(height: 16),

        // Helper tip card if email has link instead of code
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Received an email with a "Reset password" button instead of a code? Tap that button in your email to open the reset form directly.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: New Password ──────────────────────────
  Widget _buildStep3({required Key key}) {
    final strength = _passwordStrength(_newPassCtrl.text);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded, color: Color(0xFF10B981), size: 34),
          ),
        ),
        const SizedBox(height: 20),

        const Center(
          child: Text(
            'Create New Password',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Your identity is verified! Set a strong\nnew password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) ...[
          _buildErrorBanner(),
          const SizedBox(height: 16),
        ],

        // New Password
        _buildSheetInput(
          controller: _newPassCtrl,
          label: 'New Password',
          hint: 'Enter new password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureNew,
          suffix: IconButton(
            icon: Icon(
              _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8), size: 19,
            ),
            onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
          onChanged: (_) => setState(() {}),
        ),

        // Password strength bar
        if (_newPassCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    child: LinearProgressIndicator(
                      value: _strengthProgress(strength),
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strength,
                style: TextStyle(
                  color: _strengthColor(strength),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Confirm Password
        _buildSheetInput(
          controller: _confirmPassCtrl,
          label: 'Confirm Password',
          hint: 'Re-enter new password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirm,
          onSubmitted: (_) => _submitNewPassword(),
          suffix: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8), size: 19,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),

        const SizedBox(height: 24),

        _buildPrimaryButton(
          label: 'Update Password',
          icon: Icons.check_circle_outline_rounded,
          onPressed: _submitNewPassword,
        ),
      ],
    );
  }

  // ── Step 4: Success ───────────────────────────────
  Widget _buildSuccessScreen({required Key key}) {
    return Column(
      key: key,
      children: [
        const SizedBox(height: 24),

        // Animated success icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Password Updated!',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your password has been successfully changed.\nYou can now sign in with your new credentials.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close_rounded, color: Color(0xFFFCA5A5), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF355FE5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF355FE5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }
}

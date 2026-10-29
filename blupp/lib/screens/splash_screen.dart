import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_logo.dart';

/// Interactive, high-fidelity splash screen for Blupp AI Finance.
///
/// Features:
/// - Floating ambient water/bubble particle simulation (aquatic "blupp" theme).
/// - Layered radar ripple glow around the signature Betta Fish emblem.
/// - Dynamic AI status initialization ticker (vault security, radar calibration, intelligence sync).
/// - Smooth progress indicator with gradient emerald-cyan shimmer.
/// - Tap-to-skip gesture for instant navigation.
/// - Seamless exit transition into the authenticated or sign-in experience.
class SplashScreen extends StatefulWidget {
  final FinanceState state;
  final VoidCallback onFinish;
  final Duration duration;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    required this.state,
    required this.onFinish,
    this.duration = const Duration(milliseconds: 1100),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;
  late final AnimationController _exitController;

  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _badgeSlide;

  bool _isExiting = false;
  String _currentStatus = 'Securing encrypted vault...';
  IconData _currentIcon = Icons.shield_outlined;

  final List<_BubbleParticle> _bubbles = List.generate(
    14,
    (index) => _BubbleParticle.random(index),
  );

  @override
  void initState() {
    super.initState();

    // 1. Entry Animation (Logo & Title entrance)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _scaleIn = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _badgeSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Pulse / Breathing / Ambient Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // 3. Progress Controller (Drives the loading ticker & duration)
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.addListener(_onProgressTick);

    // 4. Exit Animation
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Kick off entry and progress
    _entryController.forward();
    if (widget.autoNavigate) {
      _progressController.forward().then((_) {
        if (mounted && !_isExiting) {
          _completeSplash();
        }
      });

      // When initial data sync finishes from Supabase, smoothly accelerate to finish
      widget.state.syncFuture.then((_) {
        if (mounted && !_isExiting && widget.autoNavigate) {
          final remaining = 1.0 - _progressController.value;
          if (remaining > 0.05 && _progressController.isAnimating) {
            _progressController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            ).then((_) {
              if (mounted && !_isExiting) {
                _completeSplash();
              }
            });
          }
        }
      });
    }
  }

  void _onProgressTick() {
    final v = _progressController.value;
    String newStatus;
    IconData newIcon;

    if (v < 0.30) {
      newStatus = 'Securing encrypted vault...';
      newIcon = Icons.shield_outlined;
    } else if (v < 0.65) {
      newStatus = 'Calibrating Safe-to-Spend radar...';
      newIcon = Icons.radar_rounded;
    } else if (v < 0.90) {
      newStatus = 'Syncing financial intelligence...';
      newIcon = Icons.auto_awesome_rounded;
    } else {
      newStatus = 'Ready';
      newIcon = Icons.check_circle_outline_rounded;
    }

    if (newStatus != _currentStatus && mounted) {
      setState(() {
        _currentStatus = newStatus;
        _currentIcon = newIcon;
      });
    }
  }

  void _completeSplash() {
    if (_isExiting) return;
    _isExiting = true;

    // Stop continuous pulse ticker and entry controllers so tests/frames cleanly settle
    _pulseController.stop();
    _entryController.stop();
    _progressController.stop();

    _exitController.forward().whenComplete(() {
      if (mounted) {
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final bgColor = isDark ? const Color(0xFF09090B) : const Color(0xFFFAFAFA);
    final textCol = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF09090B);
    final mutedCol = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _completeSplash,
        child: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            final exitProgress = _exitController.value;
            final exitOpacity = (1.0 - exitProgress).clamp(0.0, 1.0);
            final exitScale = 1.0 + (exitProgress * 0.06);

            return Opacity(
              opacity: exitOpacity,
              child: Transform.scale(
                scale: exitScale,
                child: Stack(
                  children: [
                    // 1. Ambient Background Glows
                    Positioned.fill(
                      child: _buildAmbientGlow(isDark),
                    ),

                    // 2. Underwater / "Blupp" Bubble Particle Canvas
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _BubblePainter(
                              bubbles: _bubbles,
                              progress: _pulseController.value,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),

                    // 3. Central Brand Composition
                    Center(
                      child: AnimatedBuilder(
                        animation: _entryController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.scale(
                              scale: _scaleIn.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glowing Emblem with Radar Aura
                            _buildEmblem(isDark),

                            const SizedBox(height: 28),

                            // Brand Name & AI Badge
                            _buildBrandHeader(textCol, isDark),

                            const SizedBox(height: 8),

                            // Tagline
                            Text(
                              'INTELLIGENT WEALTH OS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3.2,
                                color: mutedCol,
                              ),
                            ),

                            const SizedBox(height: 38),

                            // Dynamic Progress Bar
                            _buildProgressBar(isDark),

                            const SizedBox(height: 14),

                            // Dynamic Status Message Ticker
                            _buildStatusTicker(mutedCol),
                          ],
                        ),
                      ),
                    ),

                    // 4. Bottom Footer Badges & Skip Prompt
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.paddingOf(context).bottom + 20,
                      child: AnimatedBuilder(
                        animation: _entryController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _badgeSlide.value),
                            child: Opacity(
                              opacity: _fadeIn.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Security badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 13,
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.85),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '256-Bit Encrypted • Privacy Shield Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: mutedCol.withValues(alpha: 0.85),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Version and tap to skip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'v1.0.0',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: mutedCol.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mutedCol.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  key: const ValueKey('splash_skip_button'),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _completeSplash,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      'Tap anywhere to skip',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Ambient multi-color radial gradient backdrop
  Widget _buildAmbientGlow(bool isDark) {
    if (!isDark) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 0.8,
            colors: [
              AppTheme.primaryTeal.withValues(alpha: 0.08),
              AppTheme.secondaryCyan.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 0.95,
          colors: [
            AppTheme.primaryTeal.withValues(alpha: 0.16),
            AppTheme.secondaryCyan.withValues(alpha: 0.09),
            const Color(0xFF09090B).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// Central Fish Emblem with pulse aura and glassmorphic frame
  Widget _buildEmblem(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        final auraScale = 1.0 + (pulse * 0.12);
        final auraOpacity = (0.28 - (pulse * 0.14)).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outermost radar wave
            Transform.scale(
              scale: auraScale * 1.35,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryTeal.withValues(alpha: auraOpacity * 0.6),
                    width: 1.2,
                  ),
                ),
              ),
            ),

            // Middle glowing pulse ring
            Transform.scale(
              scale: auraScale,
              child: Container(
                width: 114,
                height: 114,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryTeal.withValues(alpha: auraOpacity),
                      AppTheme.secondaryCyan.withValues(alpha: auraOpacity * 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Glassmorphic squircle badge
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: isDark
                    ? const Color(0xFF141418).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: isDark ? 0.28 : 0.14),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Center(
                  child: BluppLogo(
                    size: 58,
                    iconOnly: true,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Title row: "blupp" + "AI" gradient pill
  Widget _buildBrandHeader(Color textColor, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'blupp',
          style: GoogleFonts.inter(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF06B6D4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'AI',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// High-tech slim capsule progress bar
  Widget _buildProgressBar(bool isDark) {
    return Container(
      width: 190,
      height: 4.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 190 * _progressController.value.clamp(0.04, 1.0),
              height: 4.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF06B6D4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Animated status ticker below progress bar
  Widget _buildStatusTicker(Color mutedColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.25),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: Row(
        key: ValueKey<String>(_currentStatus),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _currentIcon,
            size: 13,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(width: 6),
          Text(
            _currentStatus,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Particle model for floating underwater "blupp" bubbles
class _BubbleParticle {
  final double x;
  final double initialY;
  final double radius;
  final double speed;
  final double opacity;
  final double swayPhase;

  _BubbleParticle({
    required this.x,
    required this.initialY,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.swayPhase,
  });

  factory _BubbleParticle.random(int seed) {
    final rand = math.Random(seed * 7919);
    return _BubbleParticle(
      x: rand.nextDouble(),
      initialY: rand.nextDouble(),
      radius: 2.0 + rand.nextDouble() * 5.0,
      speed: 0.08 + rand.nextDouble() * 0.16,
      opacity: 0.06 + rand.nextDouble() * 0.14,
      swayPhase: rand.nextDouble() * 2 * math.pi,
    );
  }
}

/// Custom painter rendering ambient floating bubbles with soft glow
class _BubblePainter extends CustomPainter {
  final List<_BubbleParticle> bubbles;
  final double progress;
  final bool isDark;

  _BubblePainter({
    required this.bubbles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4);

    for (final b in bubbles) {
      // Calculate current vertical drift position
      final currentY = (b.initialY - (progress * b.speed)) % 1.0;
      final currentX = (b.x + math.sin((progress * 2 * math.pi) + b.swayPhase) * 0.035).clamp(0.02, 0.98);

      final center = Offset(currentX * size.width, currentY * size.height);

      // Bubble rim outline paint
      final rimPaint = Paint()
        ..color = baseColor.withValues(alpha: b.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Bubble soft fill
      final fillPaint = Paint()
        ..color = (isDark ? Colors.white : baseColor).withValues(alpha: b.opacity * 0.3)
        ..style = PaintingStyle.fill;

      // Highlight specular dot on upper-left of bubble
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: (b.opacity * 1.8).clamp(0.0, 0.8))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, b.radius, fillPaint);
      canvas.drawCircle(center, b.radius, rimPaint);

      final highlightOffset = Offset(
        center.dx - (b.radius * 0.35),
        center.dy - (b.radius * 0.35),
      );
      canvas.drawCircle(highlightOffset, (b.radius * 0.25).clamp(0.8, 1.8), highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

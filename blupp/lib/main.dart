import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/finance_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/fomo_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/profile_screen.dart';
import 'services/supabase_service.dart';
import 'widgets/blupp_avatar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Make status bar transparent with light (white) icons — removes white bar on iOS
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,        // iOS: dark bg → light icons
      statusBarIconBrightness: Brightness.light,   // Android: light icons
    ),
  );
  await SupabaseService.instance.init();
  runApp(const BluppApp());
}

class BluppApp extends StatefulWidget {
  final bool? initialAuthenticated;

  const BluppApp({super.key, this.initialAuthenticated});

  @override
  State<BluppApp> createState() => _BluppAppState();
}

class _BluppAppState extends State<BluppApp> {
  late final FinanceState _financeState;

  @override
  void initState() {
    super.initState();
    _financeState = FinanceState(initialAuthenticated: widget.initialAuthenticated);
    _financeState.syncWithSupabase();
  }

  @override
  void dispose() {
    _financeState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blupp AI Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: ListenableBuilder(
        listenable: _financeState,
        builder: (context, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _financeState.isAuthenticated
                ? MainNavigationShell(
                    key: const ValueKey('authenticated_shell'),
                    state: _financeState,
                  )
                : SignInScreen(
                    key: const ValueKey('sign_in_screen'),
                    state: _financeState,
                  ),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final FinanceState state;

  const MainNavigationShell({super.key, required this.state});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentTabIndex = 0;

  void _navigateToTab(int index) {
    if (_currentTabIndex == index) return;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    // Height of the floating navbar: 56px content + top padding + bottom safe area
    final navbarHeight = 56.0 + bottomPadding.clamp(8.0, 40.0);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // High-performance tab content via IndexedStack (maintains state with 0 drag jank)
          Padding(
            padding: EdgeInsets.only(bottom: navbarHeight),
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                HomeScreen(
                  state: widget.state,
                  onNavigateTab: _navigateToTab,
                ),
                TrackingScreen(
                  state: widget.state,
                ),
                AnalyticsScreen(
                  state: widget.state,
                ),
                FomoScreen(
                  state: widget.state,
                ),
                CalendarScreen(
                  state: widget.state,
                ),
                ProfileScreen(
                  state: widget.state,
                ),
              ],
            ),
          ),

          // Floating glass navbar (responsive for mobile, iOS, and Web)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: AppTheme.isDark ? 0.35 : 0.10,
                        ),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.isDark
                              ? const Color(0xE609090B)
                              : const Color(0xE6FFFFFF),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppTheme.isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              index: 0,
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home_rounded,
                              label: 'Home',
                            ),
                            _buildNavItem(
                              index: 1,
                              icon: Icons.receipt_long_outlined,
                              activeIcon: Icons.receipt_long_rounded,
                              label: 'Expenses',
                            ),
                            _buildNavItem(
                              index: 2,
                              icon: Icons.insights_outlined,
                              activeIcon: Icons.insights_rounded,
                              label: 'Analytics',
                            ),
                            _buildNavItem(
                              index: 3,
                              icon: Icons.auto_awesome_outlined,
                              activeIcon: Icons.auto_awesome_rounded,
                              label: 'FOMO AI',
                            ),
                            _buildNavItem(
                              index: 4,
                              icon: Icons.calendar_today_outlined,
                              activeIcon: Icons.calendar_month_rounded,
                              label: 'Calendar',
                            ),
                            _buildProfileNavItem(index: 5),
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
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToTab(index),
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem({required int index}) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToTab(index),
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: BluppAvatar(
                    state: widget.state,
                    size: 24,
                    showEditBadge: false,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryTeal,
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
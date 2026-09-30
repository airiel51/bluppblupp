import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return ListenableBuilder(
      listenable: _financeState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Blupp AI Finance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _financeState.themeMode,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _financeState.isAuthenticated
                ? MainNavigationShell(
                    key: const ValueKey('authenticated_shell'),
                    state: _financeState,
                  )
                : SignInScreen(
                    key: const ValueKey('sign_in_screen'),
                    state: _financeState,
                  ),
          ),
        );
      },
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
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
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
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: _navigateToTab,
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.textPrimary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.dashboard_rounded, color: AppTheme.textPrimary),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.textPrimary),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.pie_chart_rounded, color: AppTheme.textPrimary),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.auto_awesome_rounded, color: AppTheme.textPrimary),
              label: 'FOMO AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.textPrimary),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, color: AppTheme.textMuted),
              activeIcon: Icon(Icons.person_rounded, color: AppTheme.textPrimary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
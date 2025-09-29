import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import '../screens/login_screen.dart';
import 'state/app_state.dart';
import '../../services/notification_service.dart';
import 'package:harvestor/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class HarvestorApp extends StatelessWidget {
  const HarvestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'One Team One Mission',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
                primary: AppColors.primary,
                background: AppColors.background,
                surface: AppColors.card,
                error: AppColors.critical,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
              ),
              cardTheme: const CardThemeData(
                color: AppColors.card,
                surfaceTintColor: Colors.transparent,
                elevation: AppElevation.card,
                margin: EdgeInsets.all(8),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ).copyWith(
                primary: AppColors.primary,
                background: const Color(0xFF1A1A1A),
                surface: const Color(0xFF2A2A2A),
                error: AppColors.critical,
              ),
              scaffoldBackgroundColor: const Color(0xFF1A1A1A),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF2A2A2A),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.all(8),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme().apply(
                bodyColor: Colors.white70,
                displayColor: Colors.white,
              ),
            ),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                if (snap.data == null) return const LoginScreen();
                return const _RootNav();
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav();

  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;
  final _pages = const [
    DashboardScreen(),
    ReportsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onKeyboardShortcut(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.keyD &&
          HardwareKeyboard.instance.isControlPressed) {
        setState(() => _index = 0); // Ctrl+D for Dashboard
      } else if (key == LogicalKeyboardKey.keyR &&
          HardwareKeyboard.instance.isControlPressed) {
        setState(() => _index = 1); // Ctrl+R for Reports
      } else if (key == LogicalKeyboardKey.keyH &&
          HardwareKeyboard.instance.isControlPressed) {
        setState(() => _index = 2); // Ctrl+H for History
      } else if (key == LogicalKeyboardKey.keyS &&
          HardwareKeyboard.instance.isControlPressed) {
        setState(() => _index = 3); // Ctrl+S for Settings
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyboardShortcut,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1976D2), // Blue
                  Color(0xFF42A5F5), // Light blue
                  Color(0xFF64B5F6), // Lighter blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.agriculture,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _index == 0 ? 'Harvester Command Center' : app.harvesterName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          actions: [
            // Support Icon
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              tooltip: 'Support & Help',
            ),
            const SizedBox(width: 8),
            // Theme Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  app.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  app.toggleThemeMode();
                },
                tooltip: app.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              ),
            ),
            const SizedBox(width: 8),
            // Notifications
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications panel coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
            ),
            const SizedBox(width: 8),
            // User Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Text(
                  app.farmerName.isNotEmpty
                      ? app.farmerName[0].toUpperCase()
                      : 'F',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // GPS Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: _pages[_index],
        bottomNavigationBar: _buildEnhancedNavigationBar(),
      ),
    );
  }

  Widget _buildEnhancedNavigationBar() {
    const navItems = [
      _NavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        tooltip: 'Dashboard — Real-time harvester metrics',
        shortcut: 'Ctrl+D',
      ),
      _NavItem(
        icon: Icons.stacked_bar_chart_outlined,
        selectedIcon: Icons.stacked_bar_chart,
        label: 'Reports',
        tooltip: 'Reports — Analytics and harvest data',
        shortcut: 'Ctrl+R',
      ),
      _NavItem(
        icon: Icons.history_outlined,
        selectedIcon: Icons.history,
        label: 'History',
        tooltip: 'History — Past harvest records',
        shortcut: 'Ctrl+H',
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Settings',
        tooltip: 'Settings — App and device configuration',
        shortcut: 'Ctrl+S',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: navItems.asMap().entries.map((entry) {
          final item = entry.value;
          final isSelected = entry.key == _index;

          return NavigationDestination(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                key: ValueKey(isSelected),
                size: 28,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            label: item.label,
            tooltip: '${item.tooltip}\n${item.shortcut}',
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;
  final String shortcut;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
    required this.shortcut,
  });
}

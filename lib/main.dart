import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/preferences_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/metronome/metronome_screen.dart';
import 'features/gps/gps_screen.dart';
import 'features/history/history_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  // enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const CadenceApp(),
    ),
  );
}

class CadenceApp extends StatelessWidget {
  const CadenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _MainShellView();
  }
}

class _MainShellView extends ConsumerStatefulWidget {
  const _MainShellView();

  @override
  ConsumerState<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends ConsumerState<_MainShellView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    MetronomeScreen(),
    GpsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Top Segmented Pill Switcher (Metronome, GPS, History)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfacePanel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hairline),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton(0, 'METRONOME'),
                    _buildTabButton(1, 'GPS'),
                    _buildTabButton(2, 'HISTORY'),
                    _buildTabButton(3, 'SETTINGS'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        // FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _currentIndex = index;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/accessibility_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MoodDiaryApp()));
}

class MoodDiaryApp extends ConsumerWidget {
  const MoodDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Mood Diary',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleNotifier.supportedLocales,
      theme: AppTheme.buildTheme(
        brightness: Brightness.light,
        accessibility: accessibility,
        appColorScheme: themeSettings.colorScheme,
      ),
      darkTheme: AppTheme.buildTheme(
        brightness: Brightness.dark,
        accessibility: accessibility,
        appColorScheme: themeSettings.colorScheme,
      ),
      themeMode: themeSettings.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Keys to trigger rebuilds when returning to screens
  final _homeKey = GlobalKey<HomeScreenState>();
  final _historyKey = GlobalKey<HistoryScreenState>();
  final _statisticsKey = GlobalKey<StatisticsScreenState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeKey),
          HistoryScreen(key: _historyKey),
          StatisticsScreen(key: _statisticsKey),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          // Trigger reload when switching to data screens
          if (index == 0) {
            _homeKey.currentState?.reload();
          } else if (index == 1) {
            _historyKey.currentState?.reload();
          } else if (index == 2) {
            _statisticsKey.currentState?.reload();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n?.today ?? 'Today',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n?.history ?? 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n?.statistics ?? 'Statistics',
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n?.more ?? 'More',
          ),
        ],
      ),
    );
  }
}

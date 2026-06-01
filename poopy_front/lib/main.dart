import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

// 🌗 Le provider Riverpod pour gérer l'état du thème global
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Portrait only for now
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: PoopyApp()));
}

class PoopyApp extends ConsumerWidget {
  const PoopyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final isDark = currentThemeMode == ThemeMode.dark;

    // ⚡️ Ajustement de la couleur des icônes de la barre d'état système
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp.router(
      title: 'Poopy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark, // 🌙 Ton AppTheme.dark gère enfin la racine !
      themeMode: currentThemeMode, 
      routerConfig: router,
    );
  }
}
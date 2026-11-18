import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'widgets/gyro_splash_screen.dart';
import 'services/locale_controller.dart';
import 'services/user_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localeController.load();
  await userState.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FlixoraApp());
}

class FlixoraApp extends StatelessWidget {
  const FlixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (_, override, __) {
        return MaterialApp(
          title: 'Sky Live',
          debugShowCheckedModeBanner: false,
          theme: buildDarkTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeMode.dark,
          locale: override,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GyroSplashScreen(),
        );
      },
    );
  }
}

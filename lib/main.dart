import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/wardrobe_service.dart';
import 'services/ai_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.loadFromStorage();

  final wardrobeService = WardrobeService();
  if (authService.isLoggedIn) {
    await wardrobeService.setUserScope(authService.currentUser!.email);
  }

  final themeProvider = ThemeProvider();
  if (authService.isLoggedIn) {
    themeProvider.setDefaultForGender(authService.currentUser!.gender);
  }

  runApp(StyleMateApp(
    authService: authService,
    wardrobeService: wardrobeService,
    themeProvider: themeProvider,
  ));
}

class StyleMateApp extends StatelessWidget {
  final AuthService authService;
  final WardrobeService wardrobeService;
  final ThemeProvider themeProvider;

  const StyleMateApp({
    super.key,
    required this.authService,
    required this.wardrobeService,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: wardrobeService),
        Provider(create: (_) => AiService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'StyleMate',
            debugShowCheckedModeBanner: false,
            theme: buildThemeData(themeProvider.palette),
            // Safety net behind every page, so there is never a black
            // flash while the themed background is painting.
            builder: (context, child) => ColoredBox(
              color: themeProvider.palette.background,
              child: child,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

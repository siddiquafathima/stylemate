import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/stylemate_wordmark.dart';
import 'auth/auth_screen.dart';
import 'onboarding/personalize_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      if (!auth.isLoggedIn) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
      } else if (auth.currentUser!.gender == 'unspecified') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PersonalizeScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StyleMateWordmark(size: 38),
              const SizedBox(height: 10),
              Text(
                'YOUR WARDROBE, WORN SMARTER',
                style: GoogleFonts.poppins(
                  color: palette.textPrimary.withOpacity(0.6),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
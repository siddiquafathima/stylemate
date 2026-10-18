import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum IconStyle { outlined, rounded, sharp }

enum PatternKind { hearts, dots, geometric }

enum HeadingFont { serif, condensed, elegant }

/// One of the app's three looks. Everything visual that differs between
/// themes lives here -- colors, corner shape, icon style, heading font
/// and the decorative background pattern.
class AppPalette {
  final String key;
  final String displayName;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color textPrimary;
  final double radius;
  final IconStyle iconStyle;
  final PatternKind pattern;
  final HeadingFont headingFont;
  final Color gradientTop;
  final Color gradientBottom;

  const AppPalette({
    required this.key,
    required this.displayName,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.textPrimary,
    required this.radius,
    required this.iconStyle,
    required this.pattern,
    required this.headingFont,
    required this.gradientTop,
    required this.gradientBottom,
  });
}

class AppPalettes {
  /// Beige. The default: used on splash, login/signup, after logging
  /// out, and for anyone who picks "Neutral".
  static const neutral = AppPalette(
    key: 'neutral',
    displayName: 'Beige',
    description: 'Calm, warm and neutral.',
    primary: Color(0xFF8A6F4E),
    secondary: Color(0xFFE6D8C3),
    accent: Color(0xFFEADFC9),
    background: Color(0xFFF6EFE4),
    textPrimary: Color(0xFF3B2E22),
    radius: 16,
    iconStyle: IconStyle.outlined,
    pattern: PatternKind.dots,
    headingFont: HeadingFont.elegant,
    gradientTop: Color(0xFFF9F3E9),
    gradientBottom: Color(0xFFEEE1CC),
  );

  /// Pink, for girls: soft, rounded, pinterest-style.
  static const blush = AppPalette(
    key: 'blush',
    displayName: 'Pink',
    description: 'Soft, rounded and girly.',
    primary: Color(0xFFE8478C),
    secondary: Color(0xFFF9C9DD),
    accent: Color(0xFFFFD6E6),
    background: Color(0xFFFFF1F6),
    textPrimary: Color(0xFF4A1D33),
    radius: 24,
    iconStyle: IconStyle.rounded,
    pattern: PatternKind.hearts,
    headingFont: HeadingFont.serif,
    gradientTop: Color(0xFFFFE3EE),
    gradientBottom: Color(0xFFFFF8FB),
  );

  /// Blue and black, for boys: sharp, bold, streetwear.
  static const midnight = AppPalette(
    key: 'midnight',
    displayName: 'Blue & Black',
    description: 'Sharp, bold and clean.',
    primary: Color(0xFF1F4FD8),
    secondary: Color(0xFFBFD3FA),
    accent: Color(0xFFC9DAF8),
    background: Color(0xFFEAF0F9),
    textPrimary: Color(0xFF0B0F1A),
    radius: 10,
    iconStyle: IconStyle.sharp,
    pattern: PatternKind.geometric,
    headingFont: HeadingFont.condensed,
    gradientTop: Color(0xFFD7E3F6),
    gradientBottom: Color(0xFFF3F7FD),
  );

  static const all = [neutral, blush, midnight];

  static AppPalette byKey(String key) {
    return all.firstWhere((p) => p.key == key, orElse: () => neutral);
  }

  /// Gender picks the theme: female -> pink, male -> blue & black,
  /// anything else (neutral / not chosen yet) -> beige.
  static AppPalette defaultForGender(String gender) {
    if (gender == 'female') return blush;
    if (gender == 'male') return midnight;
    return neutral;
  }
}

class AppType {
  static TextStyle heading(HeadingFont font, Color color, {double size = 28}) {
    switch (font) {
      case HeadingFont.condensed:
        return GoogleFonts.anton(color: color, fontSize: size, height: 1.1, letterSpacing: 0.4);
      case HeadingFont.elegant:
        return GoogleFonts.cormorantGaramond(color: color, fontSize: size * 1.1, height: 1.1, fontWeight: FontWeight.w700);
      case HeadingFont.serif:
        return GoogleFonts.playfairDisplay(color: color, fontSize: size, height: 1.1, fontWeight: FontWeight.w700);
    }
  }

  static TextStyle eyebrow(Color color) => GoogleFonts.poppins(
        color: color,
        fontSize: 10,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w600,
      );
}

/// Icons that change character with the theme: outlined (beige),
/// rounded (pink) or sharp (blue & black).
class AppIcons {
  static IconData _pick(IconStyle s, IconData outlined, IconData rounded, IconData sharp) {
    switch (s) {
      case IconStyle.outlined:
        return outlined;
      case IconStyle.rounded:
        return rounded;
      case IconStyle.sharp:
        return sharp;
    }
  }

  static IconData home(IconStyle s) => _pick(s, Icons.home_outlined, Icons.home_rounded, Icons.home_sharp);
  static IconData wardrobe(IconStyle s) => _pick(s, Icons.checkroom_outlined, Icons.checkroom_rounded, Icons.checkroom_sharp);
  static IconData outfits(IconStyle s) => _pick(s, Icons.add_box_outlined, Icons.add_circle_rounded, Icons.add_box_sharp);
  static IconData calendar(IconStyle s) => _pick(s, Icons.calendar_today_outlined, Icons.calendar_month_rounded, Icons.calendar_today_sharp);
  static IconData profile(IconStyle s) => _pick(s, Icons.person_outline, Icons.person_rounded, Icons.person_sharp);
  static IconData addPhoto(IconStyle s) => _pick(s, Icons.add_a_photo_outlined, Icons.add_a_photo_rounded, Icons.add_a_photo_sharp);
  static IconData help(IconStyle s) => _pick(s, Icons.help_outline, Icons.help_rounded, Icons.help_sharp);
  static IconData search(IconStyle s) => _pick(s, Icons.search, Icons.search_rounded, Icons.search_sharp);
  static IconData bell(IconStyle s) => _pick(s, Icons.notifications_outlined, Icons.notifications_rounded, Icons.notifications_sharp);
}

/// The app's background: a soft gradient plus a light decorative pattern
/// (hearts and sparkles for pink, geometric marks for blue & black,
/// dots for beige), instead of a plain flat colour.
class ThemedBackground extends StatelessWidget {
  final AppPalette palette;
  final Widget child;
  const ThemedBackground({super.key, required this.palette, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.gradientTop, palette.gradientBottom],
        ),
      ),
      child: CustomPaint(
        painter: _PatternPainter(palette.pattern, palette.primary),
        child: child,
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final PatternKind kind;
  final Color color;
  _PatternPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rnd = Random(7);
    final count = (size.width * size.height / 8000).round().clamp(14, 110);
    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final s = 4 + rnd.nextDouble() * 7;
      final opacity = 0.07 + rnd.nextDouble() * 0.11;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      final type = rnd.nextInt(3);
      switch (kind) {
        case PatternKind.hearts:
          if (type == 0) {
            canvas.drawPath(_heart(Offset(x, y), s), paint);
          } else if (type == 1) {
            canvas.drawPath(_sparkle(Offset(x, y), s * 1.2), paint);
          } else {
            canvas.drawCircle(Offset(x, y), s * 0.35, paint);
          }
          break;
        case PatternKind.dots:
          if (type == 0) {
            canvas.drawCircle(Offset(x, y), s * 0.4, paint);
          } else if (type == 1) {
            canvas.drawPath(_sparkle(Offset(x, y), s * 0.9), paint);
          } else {
            canvas.drawCircle(Offset(x, y), s * 0.18, paint);
          }
          break;
        case PatternKind.geometric:
          final stroke = Paint()
            ..color = color.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4;
          if (type == 0) {
            canvas.drawLine(Offset(x - s, y), Offset(x + s, y), stroke);
            canvas.drawLine(Offset(x, y - s), Offset(x, y + s), stroke);
          } else if (type == 1) {
            canvas.drawLine(Offset(x - s, y + s), Offset(x + s, y - s), stroke);
          } else {
            canvas.drawCircle(Offset(x, y), s * 0.7, stroke);
          }
          break;
      }
    }
  }

  Path _heart(Offset c, double s) {
    final p = Path();
    p.moveTo(c.dx, c.dy + s * 0.9);
    p.cubicTo(c.dx - s * 1.2, c.dy + s * 0.1, c.dx - s * 0.7, c.dy - s * 0.9, c.dx, c.dy - s * 0.3);
    p.cubicTo(c.dx + s * 0.7, c.dy - s * 0.9, c.dx + s * 1.2, c.dy + s * 0.1, c.dx, c.dy + s * 0.9);
    p.close();
    return p;
  }

  Path _sparkle(Offset c, double s) {
    final p = Path();
    p.moveTo(c.dx, c.dy - s);
    p.lineTo(c.dx + s * 0.25, c.dy - s * 0.25);
    p.lineTo(c.dx + s, c.dy);
    p.lineTo(c.dx + s * 0.25, c.dy + s * 0.25);
    p.lineTo(c.dx, c.dy + s);
    p.lineTo(c.dx - s * 0.25, c.dy + s * 0.25);
    p.lineTo(c.dx - s, c.dy);
    p.lineTo(c.dx - s * 0.25, c.dy - s * 0.25);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) => old.kind != kind || old.color != color;
}

/// Wraps every page in the themed background, so each screen gets the
/// pattern (instead of needing it added screen by screen) without
/// ghosting during page transitions.
class _ThemedTransitions extends PageTransitionsBuilder {
  final AppPalette palette;
  const _ThemedTransitions(this.palette);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ThemedBackground(palette: palette, child: child),
    );
  }
}

ThemeData buildThemeData(AppPalette palette) {
  final ink = palette.textPrimary;
  final hairline = ink.withOpacity(0.16);
  final r = palette.radius;
  final inputR = r.clamp(8.0, 18.0).toDouble();
  final dialogR = r.clamp(10.0, 24.0).toDouble();
  final OutlinedBorder buttonShape =
      r >= 20 ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  final base = GoogleFonts.poppinsTextTheme().apply(bodyColor: ink, displayColor: ink);
  final textTheme = base.copyWith(
    displayLarge: AppType.heading(palette.headingFont, ink, size: 44),
    displayMedium: AppType.heading(palette.headingFont, ink, size: 36),
    displaySmall: AppType.heading(palette.headingFont, ink, size: 30),
    headlineLarge: AppType.heading(palette.headingFont, ink, size: 28),
    headlineMedium: AppType.heading(palette.headingFont, ink, size: 24),
    headlineSmall: AppType.heading(palette.headingFont, ink, size: 20),
  );

  return ThemeData(
    useMaterial3: true,
    // Transparent so the themed background (gradient + pattern) shows
    // through every screen.
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.light(
      primary: palette.primary,
      secondary: palette.secondary,
      surface: palette.background,
      tertiary: palette.accent,
    ),
    textTheme: textTheme,
    iconTheme: IconThemeData(color: palette.primary),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android: _ThemedTransitions(palette),
      TargetPlatform.iOS: _ThemedTransitions(palette),
    }),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: IconThemeData(color: ink),
      actionsIconTheme: IconThemeData(color: palette.primary),
      titleTextStyle: AppType.heading(palette.headingFont, ink, size: 24),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: buttonShape,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        shape: buttonShape,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primary,
        side: BorderSide(color: palette.primary, width: 1.4),
        shape: buttonShape,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primary,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.92),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r),
        side: BorderSide(color: hairline),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedColor: palette.accent,
      side: BorderSide(color: hairline),
      shape: r >= 20 ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
      labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: ink),
      showCheckmark: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(inputR), borderSide: BorderSide(color: hairline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(inputR), borderSide: BorderSide(color: hairline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(inputR), borderSide: BorderSide(color: palette.primary, width: 1.6)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogR), side: BorderSide(color: hairline)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.94),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: palette.accent,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? palette.primary : ink.withOpacity(0.55),
          )),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ink),
      ),
    ),
    dividerTheme: DividerThemeData(color: hairline, thickness: 1),
  );
}

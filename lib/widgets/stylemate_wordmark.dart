import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

/// The app name as ONE word, "StyleMate", in two colours:
/// "Style" in the theme's text colour, "Mate" in the theme colour.
class StyleMateWordmark extends StatelessWidget {
  final double size;
  const StyleMateWordmark({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final base = AppType.heading(palette.headingFont, palette.textPrimary, size: size);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: 'Style', style: base.copyWith(color: palette.textPrimary)),
          TextSpan(text: 'Mate', style: base.copyWith(color: palette.primary)),
        ],
      ),
    );
  }
}

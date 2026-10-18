import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Holds the currently active palette. Splash/login/signup use
/// [neutral] by default; after gender selection + theme picker,
/// the rest of the app reflects the chosen palette.
class ThemeProvider extends ChangeNotifier {
  AppPalette _palette = AppPalettes.neutral;

  AppPalette get palette => _palette;

  void useNeutral() {
    _palette = AppPalettes.neutral;
    notifyListeners();
  }

  void setDefaultForGender(String gender) {
    _palette = AppPalettes.defaultForGender(gender);
    notifyListeners();
  }

  void setTheme(String key) {
    _palette = AppPalettes.byKey(key);
    notifyListeners();
  }
}

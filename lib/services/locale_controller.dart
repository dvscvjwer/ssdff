import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's language override.
///
/// `null` => follow the device language.
/// A specific Locale (e.g. `Locale('en')` or `Locale('ar')`) => override it.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  static const _prefsKey = 'app_locale_override';
  static const supported = <Locale>[Locale('en'), Locale('ar')];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      value = null;
    } else {
      value = Locale(code);
    }
  }

  Future<void> setOverride(Locale? locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final localeController = LocaleController();

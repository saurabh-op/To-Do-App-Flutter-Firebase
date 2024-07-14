import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static const String _firstLaunchKey = 'firstLaunch';

  static Future<void> clearSharedPreferencesIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      await prefs.clear();

      await prefs.setBool(_firstLaunchKey, false);
    }
  }
}

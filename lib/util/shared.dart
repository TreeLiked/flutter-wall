import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static SharedPreferences sp;
  static Future<String> readStringValue(String key) async {
    await initInstance();
    String s = sp.getString(key);
    return s;
  }

  static Future<bool> setStringValue(String key, String value) async {
    await initInstance();
    return sp.setString(key, value);
  }

  static Future<List<String>> readListStringValue(String key) async {
    await initInstance();
    List<String> s = sp.getStringList(key);
    return s;
  }

  static Future<bool> setListStringValue(
      String key, List<String> values) async {
    await initInstance();
    bool res = await sp.setStringList(key, values);
    return res;
  }

  static void initInstance() async {
    if (sp == null) {
      sp = await SharedPreferences.getInstance();
    }
  }
}

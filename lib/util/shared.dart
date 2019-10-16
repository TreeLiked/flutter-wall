import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static Future<String> readStringValue(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String s = sp.getString(key);
    return s;
  }
}

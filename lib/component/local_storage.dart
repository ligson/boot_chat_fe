import 'package:shared_preferences/shared_preferences.dart';

class MyLocalStorage {
  static SharedPreferences? _instance;

  static Future<void> _initInstance() async {
    _instance = await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> getInstance() async {
    if (_instance == null) {
      await _initInstance();
    }
    return _instance!;
  }

  static Future<void> putData(String key, String value) async {
    final instance = await getInstance();
    await instance.setString(key, value);
  }

  static Future<String?> getData(String key) async {
    final instance = await getInstance();
    return instance.getString(key);
  }

  static Future<bool> removeData(String key) async {
    final instance = await getInstance();
    return instance.remove(key);
  }
}

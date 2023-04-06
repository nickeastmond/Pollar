import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';



class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static StreamingSharedPreferences? _preferences;

  SharedPreferencesService._internal();

  static Future<SharedPreferencesService?> getInstance() async {
    _instance ??= SharedPreferencesService._internal();
    _preferences ??= await StreamingSharedPreferences.instance;
    return _instance;
  }

  StreamingSharedPreferences? get preferences => _preferences;
}

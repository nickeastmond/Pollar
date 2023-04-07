import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class PositionAdapter {
  static String encode(Position position) {
    return "${position.latitude},${position.longitude},${position.accuracy},${position.altitude},${position.heading},${position.speed},${position.speedAccuracy},${position.timestamp}";
  }

  static Position decode(String value) {
    List<String> parts = value.split(",");
    return Position(
      latitude: double.parse(parts[0]),
      longitude: double.parse(parts[1]),
      accuracy: double.parse(parts[2]),
      altitude: double.parse(parts[3]),
      heading: double.parse(parts[4]),
      speed: double.parse(parts[5]),
      speedAccuracy: double.parse(parts[6]),
      timestamp: DateTime.parse(parts[7]),
    );
    
  }

  //GET POSITION FROM SHARED PREFS, WAY FASTER THAN USING GEO.
  static Future<Position?> getFromSharedPreferences(
      String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(key);
    if (value != null) {
      return decode(value);
    }
    return null;
  }

  static Future<bool> saveToSharedPreferences(
      String key, Position position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, encode(position));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Position/position_adapter.dart';

Future<bool> getLocation() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle the case where the user has not granted permission
        return false;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    PositionAdapter.saveToSharedPreferences("location", position);
    final prefs = await SharedPreferences.getInstance();
    print("Geolocation is: ");
    print(prefs.getString("location") ?? "THERE IS NO CURREnt LOCATION!!");
    return true;
    }
    catch (e) {
        return false;
    }
  }


void checkLocationEnabled(BuildContext context) async {
  bool locationEnabled = await getLocation();
  if (!locationEnabled && context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enable Location Services"),
          content: const Text("Please enable location services to use this app."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
              SystemNavigator.pop();
            }
              
            ),
            TextButton(
              child: const Text("Settings"),
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
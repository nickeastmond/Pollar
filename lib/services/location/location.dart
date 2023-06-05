import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Position/position_adapter.dart';

Future<bool> getLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  print("PERMISSION IS: $permission");
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    // Handle the case where the user has not granted permission
    debugPrint("Permission Denied");
    final position = Position(
      latitude: 0,
      longitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    PositionAdapter.saveToSharedPreferences("virtualLocation", position);
    PositionAdapter.savePermissionToSharedPreferences("locationGranted", false);
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("Radius", 5.0);
    print("Geolocation is: ${prefs.getString("virtualLocation") ?? "THERE IS NO CURRENT LOCATION!!"}");
    shouldRequestLocation = true;
    return false;
  }

  //DEVICE DOESNT SUPPORT LOCATION SERVICES
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("Location service is disabled");
    shouldRequestLocation = true;
    return false;
  }

  shouldRequestLocation = false;

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  debugPrint("Setting current location");
  PositionAdapter.saveToSharedPreferences("virtualLocation", position);
  PositionAdapter.saveToSharedPreferences("physicalLocation", position);
  PositionAdapter.savePermissionToSharedPreferences("locationGranted", true);

  final prefs = await SharedPreferences.getInstance();
  prefs.setDouble("Radius", 5.0);
  print("Geolocation is: ${prefs.getString("virtualLocation") ?? "THERE IS NO CURRENT LOCATION!!"}");
  return true;
}



Future<bool> checkLocationEnabled(BuildContext context) async {
  bool locationEnabled = await getLocation();
    print("checking location" );
  if (!locationEnabled && context.mounted ) {
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
              
                Navigator.pop(context); // Close the dialog
              
            }
              
            ),
            TextButton(
              child: const Text("Settings"),
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  
  return locationEnabled;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Position/position_adapter.dart';

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

_saveLocationToFirestore() async {
  Position _currentPosition;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (_currentPosition != null) {
      await firestore.collection('User').add({
        'position': GeoPoint(
            _currentPosition.latitude, _currentPosition.longitude)
      });
    }
  }
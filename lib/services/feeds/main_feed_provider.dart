import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Poll/poll_model.dart';
import '../../model/Position/position_adapter.dart';
import 'feed_provider.dart';

class LocationData {
  final LatLng latLng;
  final List<Placemark> placemarks;
  final int radius;
  

  LocationData(
      {required this.latLng, required this.placemarks, required this.radius});
}

class MainFeedProvider extends FeedProvider {
  List<PollFeedObject> _items = []; // Implement items in the subclass
   LatLng _userLocation = LatLng(0, 0);
  final MapController mapController = MapController();
  bool isLoading = false;


  LocationData? _locationData; // Store the location data here
  LocationData? get locationData => _locationData; // Define the getter

  set locationData(LocationData? value) {
    _locationData = value;
    notifyListeners(); // Notify listeners when _locationData changes
  }

  Future<LocationData> _getCurrentLocation() async {
    debugPrint("executing get location");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final position = await PositionAdapter.getFromSharedPreferences("virtualLocation");
    _userLocation = LatLng(position!.latitude, position.longitude);
    mapController.move(_userLocation, 13);
    List<Placemark> placemark = await placemarkLocation(_userLocation);
    return LocationData(
        latLng: _userLocation,
        placemarks: placemark,
        radius: prefs.getDouble('Radius')!.toInt());
  }

  Future<List<Placemark>> placemarkLocation(LatLng location) async {
    try {
      return await placemarkFromCoordinates(
          location.latitude, location.longitude);
    } catch (e) {
      return [Placemark()];
    }
  }

  @override
  List<PollFeedObject> get items => _items;
  Future<bool> geoPointsDistance(
      Position p1, Position p2, double? r1) async {
    double metersToMilesFactor = 0.000621371;
    // Calculate the distance between the two points
    double distance = Geolocator.distanceBetween(
        p1.latitude, p1.longitude, p2.latitude, p2.longitude);
    // Check if the distance is less than or equal to the radius
    return (distance * metersToMilesFactor) <= (r1!);
  }
  @override
  Future<void> fetchInitial(int limit) async {
    debugPrint("fetchin initial");
    isLoading = true; // Set isLoading to true when starting the fetch

    
    _getCurrentLocation().then((locationData) {
      _locationData = locationData; // Set the initial location data
    });
    // Define the user's current location
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final position = await PositionAdapter.getFromSharedPreferences("virtualLocation");
    final double userLat = position!.latitude;
    final double userLong = position.longitude;
    final double? userRad = prefs.getDouble('Radius'); // MILES
    print("Rad is: ${userRad}");
    final currentLocation = Position(
        latitude: userLat,
        longitude: userLong,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
        
    final snapshot =
        await FirebaseFirestore.instance.collection('Poll').limit(limit).get();
    _items = [];

    // Iterate over the documents in the snapshot and check if their circles overlap with the user's circle
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      // Get the document's geopoint and radius
      
    final userId = doc.data()["userId"];
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
      PollarUser user = PollarUser.fromDoc(userSnapshot); 
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id ,user );
      GeoPoint locationData = doc.data()['locationData'];
      final otherLocation = Position(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
       
      final bool overlap = await geoPointsDistance(
          currentLocation, otherLocation, userRad);

      // Check if the circles overlap
      if (overlap) {
        _items.add(obj);
      }
    }
    _items = _items.toList();

    _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));
    print("notifyling listerners");
    notifyListeners();
    isLoading  = false;
    
  }

  
}

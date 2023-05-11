import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/polls_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/Position/position_adapter.dart';

import 'open_street_map_search_and_pick.dart';

class LocationData {
  final LatLng latLng;
  LocationData({required this.latLng});
}

Future<LocationData> _getCurrentLocation() async {
  LatLng userLocation = LatLng(0, 0);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final position = await PositionAdapter.getFromSharedPreferences("location");
  userLocation = LatLng(prefs.getDouble('Latitude') ?? position!.latitude,
      prefs.getDouble('Longitude') ?? position!.longitude);
  debugPrint("setting state to $userLocation");
  return LocationData(latLng: userLocation);
}

// Future<void> storeMapsData(int radius, double long, double lat) async {
//   print("new Postion: ${lat} ${long}");
//   Position newPosition = Position(accuracy: 0, latitude: lat, longitude: long, altitude: 0, speed: 0,heading: 0,speedAccuracy: 0,timestamp: DateTime.now());
//   PositionAdapter.saveToSharedPreferences("location", newPosition);

// }

Future<void> storeMapsData(int var1, double var2, double var3) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('Radius', var1);
  prefs.setDouble('Longitude', var2);
  prefs.setDouble('Latitude', var3);
}

class CreateMapPage extends StatefulWidget {
  const CreateMapPage({super.key});
  @override
  State<CreateMapPage> createState() => CreateMapPageState();
}

class CreateMapPageState extends State<CreateMapPage> {
  late int _value; //Default

  @override
  void initState() {
    super.initState();
    _getValue();
  }

  Future<void> _getValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = prefs.getInt('Radius') ?? 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _getCurrentLocation(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
        if (snapchat.hasData) {
          final LocationData currentLocation = snapchat.data;
          return PollsTheme(builder: (context, theme) {
            return Scaffold(
                appBar: AppBar(
                  elevation: 2,
                  title: const Text('Map'),
                  backgroundColor: theme.primaryColor,
                ),
                body: SingleChildScrollView(
                    child: Column(children: [
                  Container(
                      color: Colors.white,
                      child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            // const Icon(
                            //   Icons.add_location_alt,
                            //   size: 40,
                            // ),
                            const SizedBox(
                              width: 15,
                            ),
                            const Text(
                              "Radius:",
                              style: TextStyle(
                                height: 1.4,
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Expanded(
                                child: Slider(
                                    value: _value.toDouble(),
                                    min: 1.0,
                                    max: 20.0,
                                    divisions: 10,
                                    activeColor: theme.primaryColor,
                                    inactiveColor: theme.secondaryHeaderColor,
                                    label: "$_value mi",
                                    onChanged: (double newValue) {
                                      setState(() {
                                        _value = newValue.round();
                                      });
                                    },
                                    semanticFormatterCallback:
                                        (double newValue) {
                                      return '${newValue.round()} miles';
                                    })),
                          ])),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 115,
                    child: OpenStreetMapSearchAndPick(
                        center: LatLong(currentLocation.latLng.latitude,
                            currentLocation.latLng.longitude),
                        buttonColor: theme.primaryColor,
                        locationPinIconColor: theme.primaryColor,
                        buttonText: 'Set Feed Location',
                        onPicked: (pickedData) {
                          setState(() {
                            storeMapsData(_value, pickedData.latLong.longitude,
                                    pickedData.latLong.latitude)
                                .then((_) => Navigator.pop(context, true));
                          });
                        }),
                  )
                ])));
          });
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

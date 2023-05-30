import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/polls_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/Position/position_adapter.dart';

import 'navigation/feed_page.dart';
import 'open_street_map_search_and_pick.dart';

class LocationData {
  final LatLng latLng;
  LocationData({required this.latLng});
}

Future<LocationData> _getCurrentLocation() async {
  LatLng userLocation = LatLng(0, 0);
  final position = await PositionAdapter.getFromSharedPreferences("virtualLocation");
  userLocation = LatLng(position!.latitude,
      position.longitude);
  return LocationData(latLng: userLocation);
}

// Future<void> storeMapsData(int radius, double long, double lat) async {
//   print("new Postion: ${lat} ${long}");
//   Position newPosition = Position(accuracy: 0, latitude: lat, longitude: long, altitude: 0, speed: 0,heading: 0,speedAccuracy: 0,timestamp: DateTime.now());
//   PositionAdapter.saveToSharedPreferences("location", newPosition);

// }

Future<void> storeMapsData(int var1, double long, double lat) async {
  print(var1);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('Radius', var1.toDouble());
   final currentLocation = Position(
        latitude: lat,
        longitude: long,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);

    PositionAdapter.saveToSharedPreferences("virtualLocation", currentLocation);

}

class CreateMapPage extends StatefulWidget {
  const CreateMapPage({Key? key, required this.feedProvider}) : super(key: key);
  final FeedProvider feedProvider;
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
      _value = prefs.getDouble('Radius')!.toInt();
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
                                .then((_) => widget.feedProvider.fetchInitial(100).then((_) => Navigator.pop(context, true)));
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

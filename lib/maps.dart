import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class CreateMapPage extends StatefulWidget {
  const CreateMapPage({super.key});
  @override
  State<CreateMapPage> createState() => CreateMapPageState();
}

class CreateMapPageState extends State<CreateMapPage> {
  double? lat, long;
  int _value = 5;
  late int radius;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _currentLocation(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
        if (snapchat.hasData) {
          final LocationData currentLocation = snapchat.data;
          return Scaffold(
              appBar: AppBar(
                title: const Text('Map'),
                backgroundColor: Colors.green,
              ),
              body: SingleChildScrollView(
                  child: Column(children: [
                SizedBox(
                    height: 60,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(
                            Icons.add_location_alt,
                            size: 40,
                          ),
                          Expanded(
                              child: Slider(
                                  value: _value.toDouble(),
                                  min: 1.0,
                                  max: 20.0,
                                  divisions: 10,
                                  activeColor: Colors.green,
                                  inactiveColor: Colors.orange,
                                  label: 'Set radius value',
                                  onChanged: (double newValue) {
                                    setState(() {
                                      _value = newValue.round();
                                    });
                                  },
                                  semanticFormatterCallback: (double newValue) {
                                    return '${newValue.round()} miles';
                                  })),
                        ])),
                SizedBox(height: 40, child: Text("Radius (mi): $_value")),
                SizedBox(
                  height: 630,
                  child: OpenStreetMapSearchAndPick(
                      center: LatLong(currentLocation.latitude!,
                          currentLocation.longitude!),
                      buttonColor: Colors.green,
                      locationPinIconColor: Colors.green,
                      buttonText: 'Set Current Location',
                      onPicked: (pickedData) {
                        setState(() {
                          lat = pickedData.latLong.latitude;
                          long = pickedData.latLong.longitude;
                          radius = _value;
                        });
                      }),
                )
              ])));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

Future<LocationData?> _currentLocation() async {
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  Location location = Location();
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  return await location.getLocation();
}

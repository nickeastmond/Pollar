import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/polls_theme.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';
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
  final position =
      await PositionAdapter.getFromSharedPreferences("virtualLocation");
  userLocation = LatLng(position!.latitude, position.longitude);
  return LocationData(latLng: userLocation);
}

// Future<void> storeMapsData(int radius, double long, double lat) async {
//   print("new Postion: ${lat} ${long}");
//   Position newPosition = Position(accuracy: 0, latitude: lat, longitude: long, altitude: 0, speed: 0,heading: 0,speedAccuracy: 0,timestamp: DateTime.now());
//   PositionAdapter.saveToSharedPreferences("location", newPosition);

// }

Future<void> storeMapsData(int var1, double long, double lat) async {
  debugPrint(var1.toString());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('Radius', var1.toDouble());
  final currentLocation = Position(
      latitude: lat,
      longitude: long,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  await PositionAdapter.saveToSharedPreferences(
      "virtualLocation", currentLocation);
}

class CreateMapPage extends StatefulWidget {
  const CreateMapPage(
      {Key? key, required this.feedProvider, required this.fromFeed})
      : super(key: key);
  final MainFeedProvider feedProvider;
  final bool fromFeed;
  @override
  State<CreateMapPage> createState() => CreateMapPageState();
}

class CreateMapPageState extends State<CreateMapPage> {
  late int _value; //Default
  late double _max;
  late int finalValue;
  late double upperBound;

  @override
  void initState() {
    super.initState();
    _getValue();
  }

  Future<void> _getValue() async {
    final prefs = await SharedPreferences.getInstance();
    double val = await prefs.getDouble('Radius') ?? 5;
    setState(() {
      _value = val.toInt();
      finalValue = _value;
    });
  }

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext context,
      ) {
        return PollsTheme(builder: (context, theme) {
          return Stack(
            children: <Widget>[
              const ModalBarrier(
                color: Color.fromARGB(0, 0, 0, 0),
                dismissible: false,
              ),
              Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryHeaderColor,
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _max = 20.0; // Default
    upperBound = _max; // Default
    final callingClass = ModalRoute.of(context)?.settings.arguments as String?;
    if (callingClass == "NavigationPageState") {
      _max = 20.0; // Feed No Global Option
      upperBound = _max;
    } else if (callingClass == "CreatePollPageState") {
      _max = 21.0; // Poll Global Option
      upperBound = 20.0;
    }
    return FutureBuilder<LocationData?>(
      future: _getCurrentLocation(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
        if (snapchat.hasData) {
          final LocationData currentLocation = snapchat.data;
          return PollsTheme(builder: (context, theme) {
            return Scaffold(
                appBar: AppBar(
                  elevation: 2,
                  title: Text(widget.fromFeed ? 'Map' : 'Poll Location'),
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
                                    max: _max,
                                    divisions: 10,
                                    activeColor: theme.primaryColor,
                                    inactiveColor: theme.secondaryHeaderColor,
                                    label: _value > upperBound.round()
                                        ? "Global"
                                        : "$_value mi",
                                    onChanged: (double newValue) {
                                      setState(() {
                                        _value = newValue.round();
                                        if (newValue > upperBound) {
                                          finalValue = 999;
                                        } else {
                                          finalValue = _value;
                                        }
                                      });
                                    },
                                    semanticFormatterCallback:
                                        (double newValue) {
                                      if (newValue > upperBound) {
                                        return 'Global';
                                      } else {
                                        return '${newValue.round()} miles';
                                      }
                                    })),
                          ])),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 115,
                    child: OpenStreetMapSearchAndPick(
                        onGetCurrentLocationPressed: () async {
                          bool? locationGranted =
                              await PositionAdapter.getLocationStatus(
                                  "locationGranted");

                          Position? physicalLocation =
                              await PositionAdapter.getFromSharedPreferences(
                                  "physicalLocation");

                          if (locationGranted == true &&
                              physicalLocation != null) {
                            return LatLng(physicalLocation.latitude,
                                physicalLocation.longitude);
                          } else {
                            return LatLng(0, 0);
                          }
                        },
                        center: LatLong(currentLocation.latLng.latitude,
                            currentLocation.latLng.longitude),
                        buttonColor: theme.primaryColor,
                        locationPinIconColor: theme.primaryColor,
                        buttonText:
                            widget.fromFeed ? 'Set Feed Location' : 'Post',
                        onPicked: (pickedData) {
                          if (mounted)
                         {
                          setState(() async {
                            debugPrint("showing loading screen");
                            showLoadingScreen(context);
                            try {
                              if (widget.fromFeed) {
                                await storeMapsData(
                                    finalValue,
                                    pickedData.latLong.longitude,
                                    pickedData.latLong.latitude);
                                await widget.feedProvider.fetchInitial(100);
                                if (mounted) {
                                  Navigator.pop(context, true);
                                }
                              } else {
                                await storeMapsData(
                                    finalValue,
                                    pickedData.latLong.longitude,
                                    pickedData.latLong.latitude);
                                if (mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            } catch (e) {
                              var snackBar = SnackBar(
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.red,
                                content: Text(
                                  e.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                            if (mounted) Navigator.pop(context, true);
                          });}
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

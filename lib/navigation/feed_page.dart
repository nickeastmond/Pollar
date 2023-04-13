import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/polls/poll.dart';
import 'package:pollar/services/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../polls/poll_card.dart';
import '../polls_theme.dart';

class LocationData {
  final LatLng latLng;
  final List<Placemark> placemarks;

  LocationData({required this.latLng, required this.placemarks});
}

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  LatLng _userLocation = LatLng(0, 0);
  String locality = '';
  final MapController _mapController = MapController();

  Future<LocationData> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _userLocation = LatLng(position.latitude, position.longitude);
    _mapController.move(_userLocation, 13);
    debugPrint("setting state to $_userLocation");
    List<Placemark> placemark = await placemarkLocation(_userLocation);
    return LocationData(latLng: _userLocation, placemarks: placemark);
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
  initState() {
    super.initState();
    // _getCurrentLocation();
  }

  @override
  void dispose() {
    // Your own implementation
    super.dispose(); // Call super method
  }

  @override
  Widget build(BuildContext context) {
    return PollsTheme(
      builder: (context, theme) {
        return Scaffold(
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : const Color.fromARGB(255, 25, 25, 25),
          body: FutureBuilder<LocationData>(
              future: _getCurrentLocation(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 6, bottom: 0, left: 8, right: 8),
                        child: SizedBox(
                          height: 40,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              zoom: 13,
                              center: snapshot.data?.latLng ?? LatLng(0, 0),
                            ),
                            children: [
                              TileLayer(
                                backgroundColor: Colors.white,
                                retinaMode: true,
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.5,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10,
                                            color: Colors.black,
                                            offset: Offset(1.0, 1.0),
                                          ),
                                        ],
                                      ),
                                      '${snapshot.data?.placemarks.first.locality ?? "loading..."}  📍 • 5 Mi',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question: "Best restaurant in Santa Cruz?",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question:
                              "Best time of the day to go to the UCSC Gym?",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question: "What dining hall has the best food?",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question: "Should I take CSE 160 or CSE 140 next quarter?",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question: "SnE or McHenry?",
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 0),
                        child: PollCard(
                          question: "What dining hall has the best food?",
                        ),
                      ),
                    ],
                  ),
                );
              }),
        );
      },
    );
  }
}

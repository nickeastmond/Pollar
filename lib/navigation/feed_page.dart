import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../polls/poll_card.dart';
import '../polls_theme.dart';

class PollFeedObject {
  Poll poll;
  String pollId;

  PollFeedObject(this.poll, this.pollId);
}

class FeedProvider extends ChangeNotifier {
  List<PollFeedObject> _items = [];
  bool _moreItemsToLoad = false;

  List<PollFeedObject> get items => _items;
  Future<bool> geoPointsDistance(Position p1, Position p2, double? r1, double r2) async {
    double metersToMilesFactor = 0.000621371;
    // Calculate the distance between the two points
    double distance = Geolocator.distanceBetween(
        p1.latitude, p1.longitude, p2.latitude, p2.longitude);
    // Check if the distance is less than or equal to the radius
    return (distance * metersToMilesFactor) <= (r1! + r2);
  }

  Future<void> fetchInitial(int limit) async {
    debugPrint("fetchin initial");
    // Define the user's current location
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final position = await PositionAdapter.getFromSharedPreferences("location");
    final double userLat = position!.latitude;
    final double userLong = position.longitude;
    final double? userRad = prefs.getDouble('Radius');// MILES
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
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id);
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
      final bool overlap =
          await geoPointsDistance(currentLocation, otherLocation, userRad,obj.poll.radius);

      // Check if the circles overlap
      if (overlap)
      {
        _items.add(obj);
      }
    }
    _items = _items.toList();

    _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));
    print("notifyling listerners");
    notifyListeners();
  }

}

class LocationData {
  final LatLng latLng;
  final List<Placemark> placemarks;
  final int radius;

  LocationData(
      {required this.latLng, required this.placemarks, required this.radius});
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required refresh});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  LatLng _userLocation = LatLng(0, 0);
  String locality = '';
  final MapController _mapController = MapController();

  final ScrollController _scrollController = ScrollController();



  Future<LocationData> _getCurrentLocation() async {
    debugPrint("executing get location");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final position = await PositionAdapter.getFromSharedPreferences("location");
    _userLocation = LatLng(position!.latitude,
        position.longitude);
    _mapController.move(_userLocation, 13);
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
  initState() {
    super.initState();

    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Your own implementation
    // _scrollController.removeListener(_onScroll);
    super.dispose(); // Call super method
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (_, provider, __) {
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
                    return RefreshIndicator(
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        color: theme.secondaryHeaderColor,
                        onRefresh: () => provider.fetchInitial(100),
                        child: provider.items.isNotEmpty
                            ? ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: false,
                                itemCount: provider.items.length,
                                itemBuilder: (_, int index) {
                                  if (index == provider.items.length - 1 &&
                                      provider._moreItemsToLoad) {
                                    // declare the boolean and return loading indicator
                                    return const Center(
                                      heightFactor: 3,
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final pollItem = provider.items[index];

                                  if (index == 0) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 6,
                                              bottom: 0,
                                              left: 8,
                                              right: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? theme.primaryColor
                                                  : theme.cardColor,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 10,
                                                    spreadRadius: 0),
                                              ],
                                            ),
                                            height: 40,
                                            child: FlutterMap(
                                              mapController: _mapController,
                                              options: MapOptions(
                                                zoom: 13,
                                                center: snapshot.data?.latLng ??
                                                    LatLng(0, 0),
                                              ),
                                              children: [
                                                TileLayer(
                                                  backgroundColor: Colors.white,
                                                  retinaMode: true,
                                                  urlTemplate:
                                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                                  subdomains: const [
                                                    'a',
                                                    'b',
                                                    'c'
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 17.5,
                                                          shadows: [
                                                            Shadow(
                                                              blurRadius: 10,
                                                              color:
                                                                  Colors.black,
                                                              offset: Offset(
                                                                  1.0, 1.0),
                                                            ),
                                                          ],
                                                        ),
                                                        '${snapshot.data?.placemarks.first.locality ?? "loading..."}  📍 • ${snapshot.data?.radius ?? "5 Mi"} Mi',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              top: 8,
                                              bottom: 0),
                                          child: PollCard(
                                            poll: pollItem,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 8,
                                        bottom: 0),
                                    child: PollCard(poll: pollItem),
                                  );
                                },
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, bottom: 0, left: 8, right: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? theme.primaryColor
                                              : theme.cardColor,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                spreadRadius: 0),
                                          ],
                                        ),
                                        height: 40,
                                        child: FlutterMap(
                                          mapController: _mapController,
                                          options: MapOptions(
                                            zoom: 13,
                                            center: snapshot.data?.latLng ??
                                                LatLng(0, 0),
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
                                              padding:
                                                  const EdgeInsets.all(5.5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 17.5,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 10,
                                                          color: Colors.black,
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                        ),
                                                      ],
                                                    ),
                                                    '${snapshot.data?.placemarks.first.locality ?? "loading..."}  📍 • ${snapshot.data?.radius ?? "5 Mi"} Mi',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                    )
                                  ],
                                ),
                              ));
                  }),
            );
          },
        );
      },
    );
  }
}

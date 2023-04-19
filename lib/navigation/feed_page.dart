import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:provider/provider.dart';

import '../model/Poll/database/delete_all.dart';
import '../polls/poll_card.dart';
import '../polls_theme.dart';

class FeedProvider extends ChangeNotifier {
  List<Poll> _items = [];

  List<Poll> get items => _items;

  Future<void> fetchItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('Poll').get();
    _items = snapshot.docs.map((doc) => Poll.fromDoc(doc)).toList();
    notifyListeners();
  }
}

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
    final position = await PositionAdapter.getFromSharedPreferences("location");
    _userLocation = LatLng(position!.latitude, position.longitude);
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
                      color: theme.secondaryHeaderColor,
                      onRefresh: () => provider.fetchItems(),
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: provider.items.length,
                        itemBuilder: (_, int index) {
                          final item = provider.items[index];
                          final String question = item.pollData["question"];
                          final DateTime time = item.timestamp;

                          final String numComments =
                              item.numComments.toString();
                          final String votes = item.votes.toString();
                          if (index == 0) {
                            return Column(
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
                                          padding: const EdgeInsets.all(5.5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8, bottom: 0),
                                  child: PollCard(
                                    question: question,
                                    numComments: numComments,
                                    votes: votes,
                                    time: time,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8, bottom: 0),
                            child: PollCard(
                              question: question,
                              numComments: numComments,
                              votes: votes,
                              time: time,
                            ),
                          );
                        },
                      ),
                    );
                  }),
            );
          },
        );
      },
    );
  }
}

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
import '../model/Poll/database/delete_all.dart';
import '../polls/poll_card.dart';
import '../polls_theme.dart';

class PollFeedObject {
  Poll poll;
  String pollId;

  PollFeedObject(this.poll, this.pollId);
}

class FeedProvider extends ChangeNotifier {
  List<PollFeedObject> _items = [];
  bool _moreItemsToLoad = true;

  List<PollFeedObject> get items => _items;

  Future<void> fetchInitial(int limit) async {
    print("fetchin initial");
    final snapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    _items = snapshot.docs
        .map((doc) => PollFeedObject(Poll.fromDoc(doc), doc.id))
        .toList();
    if (items.isEmpty) {
      _moreItemsToLoad = false;
    } else {
      _moreItemsToLoad = true;
    }

    notifyListeners();
  }

  Future<void> fetchMore(int limit) async {
    print("Fetcjing more");
    final lastDocId = _items.lastWhere((item) => item != null).pollId;
    final lastDoc = await FirebaseFirestore.instance
        .collection("Poll")
        .doc(lastDocId)
        .get();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Poll')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
    final newItems = querySnapshot.docs
        .map((doc) => PollFeedObject(Poll.fromDoc(doc), doc.id))
        .toList();
    if (newItems.isEmpty) {
      _moreItemsToLoad = false;
    } else {
      _moreItemsToLoad = true;
    }
    _items.addAll(newItems);
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

  final ScrollController _scrollController = ScrollController();

  Future<LocationData> _getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('Radius') != null) {
      _userLocation =
          LatLng(prefs.getDouble('Latitiude')!, prefs.getDouble('Longitude')!);
    } else {
      final position =
          await PositionAdapter.getFromSharedPreferences("location");
      _userLocation = LatLng(position!.latitude, position.longitude);
    }
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

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    // Fetch new items
    await Provider.of<FeedProvider>(context, listen: false).fetchMore(6);
  }

  @override
  initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    // _getCurrentLocation();
  }

  @override
  void dispose() {
    // Your own implementation
    _scrollController.removeListener(_onScroll);
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
                      onRefresh: () => provider.fetchInitial(7),
                      child: ListView.builder(
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
                                    poll: pollItem,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8, bottom: 0),
                            child: PollCard(poll: pollItem),
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

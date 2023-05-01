import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/model/Poll/poll_model.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/model/user/pollar_user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Poll/database/delete_all.dart';
import '../polls/poll_card.dart';
import '../polls_theme.dart';

const double RADIUS = 20.0; // MILES

class PollFeedObject {
  Poll poll;
  String pollId;
  

  PollFeedObject(this.poll, this.pollId);
}

class FeedProvider extends ChangeNotifier {
  List<PollFeedObject> _items = [];
  bool _moreItemsToLoad = false;
  




  List<PollFeedObject> get items => _items;
  Future<bool> geoPointsOverlap(
    Position p1, double r1, Position p2, double r2) async {
  // Calculate the distance between the two points
  double distance = Geolocator.distanceBetween(
      p1.latitude, p1.longitude, p2.latitude, p2.longitude);

  // Calculate the sum of the radii
    double radiusSumInMeters = (r1 * 1609.344) + (r2 * 1609.344);

  print(distance);
  print(radiusSumInMeters);
  // Check if the distance is less than or equal to the sum of the radii
  return distance <= radiusSumInMeters;
}








  Future<void> fetchInitial(int limit) async {
    debugPrint("fetchin initial");
    // Define the user's current location
    
    final position = await PositionAdapter.getFromSharedPreferences("location");
    final double userLat = position!.latitude;
    final double userLong = position.longitude;
    final currentLocation = Position(latitude: userLat, longitude: userLong,timestamp: DateTime.now(),accuracy: 0,altitude: 0,heading: 0,speed: 0,speedAccuracy: 0);

    final snapshot = await FirebaseFirestore.instance
      .collection('Poll')
      .limit(limit)
      .get();
    _items = [];
    
    // Iterate over the documents in the snapshot and check if their circles overlap with the user's circle
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      // Get the document's geopoint and radius
      PollFeedObject obj = PollFeedObject(Poll.fromDoc(doc), doc.id);
      GeoPoint locationData = doc.data()['locationData'];
      final otherLocation = Position(latitude: locationData.latitude, longitude: locationData.longitude,timestamp: DateTime(9),accuracy: 0,altitude: 0,heading: 0,speed: 0,speedAccuracy: 0);
      
     final bool overlap =  await geoPointsOverlap(currentLocation,RADIUS,otherLocation,obj.poll.radius);

      
      // Check if the circles overlap
      if (overlap == true) {
        
        debugPrint("true");
        _items.add(obj);
      }
      
    }
    
    print(_items);
    _items = _items.toList();
     
    _items.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));

    

    notifyListeners();
  }

  // Future<void> fetchMore(int limit) async {
  //   try {
  //     final position =
  //         await PositionAdapter.getFromSharedPreferences("location");
  //     final double userLat = position!.latitude;
  //     final double userLong = position.longitude;
  //     final currentLocation = GeoPoint(userLat, userLong);

  //     print("Fetcjing more");
  //     final lastDocId = _items.lastWhere((item) => item != null).pollId;
  //     final lastDoc = await FirebaseFirestore.instance.collection("Poll").doc(lastDocId).get();
  //     final snapshot = await FirebaseFirestore.instance
  //     .collection('Poll')
  //     .where('locationData',
  //         isGreaterThan: GeoPoint(
  //           userLat - latIncrement(userLat, userLong),
  //           userLong - longIncrement(userLat, userLong),
  //         ))
  //     .where('locationData',
  //         isLessThan: GeoPoint(
  //           userLat + latIncrement(userLat, userLong),
  //           userLong + longIncrement(userLat, userLong),
  //         ))
      
  //     .orderBy("locationData", descending: true)
  //     .orderBy("timestamp", descending: true)
  //     .startAfter(lastDoc)
  //     .limit(limit)
  //     .get();
          
      
  //     final newItems = snapshot.docs
  //         .map((doc) => PollFeedObject(Poll.fromDoc(doc), doc.id))
  //         .toList();
      
      
  //     if (newItems.isEmpty) {
  //       _moreItemsToLoad = false;
  //     } else {
  //       _moreItemsToLoad = true;
  //     }
      
  //     newItems.sort((a, b) => b.poll.timestamp.compareTo(a.poll.timestamp));

  //     _items.addAll(newItems);

  //     // THIS COULD GET BAD IF THERE ARE A LOT OF POLLS, WE CAN CHANGE LATER

  //     notifyListeners();
  //   } catch (e) {
  //     print(e);
  //     debugPrint("No polls in database");
  //     return;
  //   }
  // }
}

class LocationData {
  final LatLng latLng;
  final List<Placemark> placemarks;
  final int radius;

  LocationData(
      {required this.latLng, required this.placemarks, required this.radius});
}

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required refresh
  });

  

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  LatLng _userLocation = LatLng(0, 0);
  String locality = '';
  final MapController _mapController = MapController();

  final ScrollController _scrollController = ScrollController();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   
  }
  Future<LocationData> _getCurrentLocation() async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final position = await PositionAdapter.getFromSharedPreferences("location");
    _userLocation = LatLng( position!.latitude,
        position.longitude);
    _mapController.move(_userLocation, 13);
    debugPrint("setting state to $_userLocation");
    List<Placemark> placemark = await placemarkLocation(_userLocation);
    return LocationData(
        latLng: _userLocation,
        placemarks: placemark,
        radius: prefs.getInt('Radius') ?? 5);
  }

  Future<List<Placemark>> placemarkLocation(LatLng location) async {
    try {
      return await placemarkFromCoordinates(
          location.latitude, location.longitude);
    } catch (e) {
      return [Placemark()];
    }
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     _fetchMore();
  //   }
  // }

  // Future<void> _fetchMore() async {
  //   // Fetch new items
  //   await Provider.of<FeedProvider>(context, listen: false).fetchMore(6);
  // }

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

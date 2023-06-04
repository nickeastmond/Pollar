import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:pollar/services/feeds/main_feed_provider.dart';
import 'package:provider/provider.dart';
import '../polls/poll_card.dart';
import '../polls_theme.dart';
import '../services/location/location.dart';

// for Android-specific issue as described here: https://github.com/Baseflow/flutter-geolocator/issues/1056
bool shouldRequestLocation = true;

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.feedProvider});
  @override
  State<FeedPage> createState() => _FeedPageState();
  final MainFeedProvider feedProvider;
  
}

class _FeedPageState extends State<FeedPage> with WidgetsBindingObserver {
  String locality = '';
  bool refresh = false;

  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //fetchFromFirebaseToSharedPreferences();
    checkLocationEnabled(context).then((val){
      debugPrint("location enabled = ${val}");
      setState(() {
        widget.feedProvider.fetchInitial(100);
      });
      
    });
    

    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Your own implementation
    // _scrollController.removeListener(_onScroll);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose(); // Call super method
  }

  // check permissions when app is resumed
  // this is when permissions are changed in app settings outside of app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("location request: ${shouldRequestLocation}" );
      
        checkLocationEnabled(context).then((val){
          debugPrint("location enabled = ${val}");
          setState(() {
            widget.feedProvider.fetchInitial(100);
          });
        });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainFeedProvider>(
      builder: (_, provider, __) {
        return PollsTheme(
          builder: (context, theme) {
            return Scaffold(
                backgroundColor: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 25, 25, 25),
                body: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    color: theme.secondaryHeaderColor,
                    onRefresh: () => provider.fetchInitial(100),
                    child: provider.items.isNotEmpty &&
                            provider.locationData != null
                        ? ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: false,
                            itemCount: provider.items.length,
                            itemBuilder: (_, int index) {
                              

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
                                        height: 50,
                                        child: FlutterMap(
                                          mapController:
                                              provider.mapController,
                                          options: MapOptions(
                                              zoom: 13,
                                              center: provider
                                                  .locationData!.latLng),
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
                                              child: Center(
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
                                                            offset: Offset(
                                                                1.0, 1.0),
                                                          ),
                                                        ],
                                                      ),
                                                      '${provider.locationData?.placemarks.first.locality ?? "loading..."}  📍 • ${provider.locationData?.radius ?? "5 Mi"} Mi',
                                                    ),
                                                  ],
                                                ),
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
                                          feedProvider: provider),
                                    ),
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 8, bottom: 0),
                                child: PollCard(
                                  poll: pollItem,
                                  feedProvider: provider,
                                ),
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
                                    height: 50,
                                    child: FlutterMap(
                                      mapController: provider.mapController,
                                      options: MapOptions(
                                          zoom: 13,
                                          center:
                                              provider.locationData?.latLng),
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
                                          child: Center(
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
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                      ),
                                                    ],
                                                  ),
                                                  '${provider.locationData?.placemarks.first.locality ?? "loading..."}  📍 • ${provider.locationData?.radius ?? "5"} Mi',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                )
                              ],
                            ),
                          )));
          },
        );
      },
    );
  }
}

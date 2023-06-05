import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/open_street_map_search_and_pick.dart';
import 'package:pollar/polls_theme.dart';
import 'package:pollar/services/feeds/global_feed_providor.dart';

import 'package:provider/provider.dart';

import '../../polls/poll_card.dart';
import '../../services/feeds/polls_created_provider.dart';

class GlobalFeedPage extends StatefulWidget {
  const GlobalFeedPage({super.key, required this.globalFeedProvider});
  @override
  State<GlobalFeedPage> createState() => _GlobalFeedPageState();
  final GlobalFeedProvider globalFeedProvider;
}

class _GlobalFeedPageState extends State<GlobalFeedPage>
    with WidgetsBindingObserver {
  bool refresh = false;

  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    print("fat");
    widget.globalFeedProvider.fetchInitial(100);
  }

  @override
  void dispose() {
    super.dispose(); // Call super method
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalFeedProvider>(
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
                    child: provider.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(), // Loading indicator
                          )
                        : provider.items.isNotEmpty
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
                                              top: 0,
                                              bottom: 0,
                                              left: 0,
                                              right: 0),
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
                                            height: 100,
                                            child: FlutterMap(
                                              mapController: MapController(),
                                              options: MapOptions(
                                                zoom: 1,
                                                center: LatLng(0, 0),
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
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, left: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 19,
                                                          shadows: [
                                                            Shadow(
                                                              blurRadius: 8,
                                                              color:
                                                                  Colors.black,
                                                              offset: Offset(
                                                                  1.0, 1.0),
                                                            ),
                                                          ],
                                                        ),
                                                        '',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 40,
                                                            bottom: 15,
                                                            left: 15,
                                                            right: 15),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            spreadRadius: 2.0,
                                                            blurRadius: 4.0,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const TextField(
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Search...',
                                                          hintStyle: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                          icon: Icon(
                                                            Icons.search,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
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
                                        left: 8.0,
                                        right: 8.0,
                                        top: 8,
                                        bottom: 0),
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
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
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

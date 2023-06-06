import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/polls_theme.dart';
import 'package:pollar/services/feeds/global_feed_provider.dart';

import 'package:provider/provider.dart';

import '../../polls/poll_card.dart';

class GlobalFeedPage extends StatefulWidget {
  const GlobalFeedPage(
      {super.key,
      required this.globalFeedProvider,
      required this.filterGlobalOnly});

  @override
  State<GlobalFeedPage> createState() => _GlobalFeedPageState();

  final GlobalFeedProvider globalFeedProvider;
  final bool filterGlobalOnly;
}

class _GlobalFeedPageState extends State<GlobalFeedPage>
    with WidgetsBindingObserver {
  bool refresh = false;

  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();
  int previousLength = 0;

  Timer? _debounce;

  @override
  initState() {
    super.initState();
    _searchController.text = "";
    widget.globalFeedProvider.fetchInitial(100);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();

    super.dispose(); // Call super method
  }

  void _performSearch(String value) {
    final currentLength = value.length;
    if (currentLength > previousLength || currentLength <= 3) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () async {
        await widget.globalFeedProvider.fetchBySearchText(value);
      });
    }
    previousLength = currentLength;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalFeedProvider>(
      builder: (_, provider, __) {
        return PollsTheme(
          builder: (context, theme) {
            return Scaffold(
              backgroundColor:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.white
                      : const Color.fromARGB(255, 25, 25, 25),
              body: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MediaQuery.of(context).platformBrightness ==
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
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black,
                                        offset: Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
                                  '',
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 12, top: 28),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(150),
                                  borderRadius: BorderRadius.circular(3.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2.0,
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    _performSearch(_searchController.text);
                                  },
                                  onFieldSubmitted: (value) {
                                    if (value != _searchController.text) {
                                      _performSearch(_searchController.text);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
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
                  Expanded(
                    child: RefreshIndicator(
                      triggerMode: RefreshIndicatorTriggerMode.onEdge,
                      color: theme.secondaryHeaderColor,
                      onRefresh: () {
                        _searchController.text = "";
                        return provider.fetchInitial(100);
                      },
                      child: provider.isLoading || provider.isSearching
                          ? const Center(
                              child:
                                  CircularProgressIndicator(), // Loading indicator
                            )
                          : provider.items.isEmpty
                              ? Container(
                                  // Empty screen
                                  )
                              : ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: false,
                                  itemCount: provider.items.length,
                                  itemBuilder: (_, int index) {
                                    final pollItem = provider.items[index];
                                    return ((pollItem.poll.radius == 999 &&
                                                widget.filterGlobalOnly) ||
                                            !widget.filterGlobalOnly)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 8,
                                                bottom: 0),
                                            child: PollCard(
                                              poll: pollItem,
                                              feedProvider: provider,
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 0,
                                          );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

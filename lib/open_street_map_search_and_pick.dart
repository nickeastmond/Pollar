// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:open_street_map_search_and_pick/widgets/wide_button.dart';

class OpenStreetMapSearchAndPick extends StatefulWidget {
  final LatLong center;
  final void Function(PickedData pickedData) onPicked;
  final Future<LatLng> Function() onGetCurrentLocationPressed;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color locationPinIconColor;
  final String buttonText;
  final String hintText;

  static Future<LatLng> nopFunction() {
    throw Exception("");
  }

  const OpenStreetMapSearchAndPick({
    Key? key,
    required this.center,
    required this.onPicked,
    this.onGetCurrentLocationPressed = nopFunction,
    this.buttonColor = Colors.blue,
    this.locationPinIconColor = Colors.blue,
    this.buttonTextColor = Colors.white,
    this.buttonText = 'Set Current Location',
    this.hintText = 'Search Location',
  }) : super(key: key);

  @override
  State<OpenStreetMapSearchAndPick> createState() =>
      _OpenStreetMapSearchAndPickState();
}

class _OpenStreetMapSearchAndPickState
    extends State<OpenStreetMapSearchAndPick> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  Timer? _debounce;
  var client = http.Client();

  void setNameCurrentPos() async {
    double latitude = _mapController.center.latitude;
    double longitude = _mapController.center.longitude;
    if (kDebugMode) {
    }
    if (kDebugMode) {
    }
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1&limit=10&importance=1';

    var response = await client.post(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

    _searchController.text = "";
    setState(() {});
  }

  void setNameCurrentPosAtInit() async {
    double latitude = widget.center.latitude;
    double longitude = widget.center.longitude;
    if (kDebugMode) {
    }
    if (kDebugMode) {
    }
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1&limit=10&importance=1';

    var response = await client.post(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

    _searchController.text = "";
    setState(() {});
  }

  @override
  void initState() {
    _mapController = MapController();

    setNameCurrentPosAtInit();

    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        var client = http.Client();
        String url =
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${event.center.latitude}&lon=${event.center.longitude}&zoom=18&addressdetails=1&limit=10&importance=1';

        var response = await client.post(Uri.parse(url));
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<dynamic, dynamic>;

        if (_searchController.text.isNotEmpty)
        {
                  _searchController.text = "";

        }
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _debounce?.cancel(); // Cancel the timer if it's active
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String? _autocompleteSelection;
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, style: BorderStyle.none),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, width: 3.0),
    );
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
              child: FlutterMap(
            options: MapOptions(
                center: LatLng(widget.center.latitude, widget.center.longitude),
                zoom: 15.0,
                maxZoom: 18,
                minZoom: 6),
            mapController: _mapController,
            children: [
              TileLayer(
                retinaMode: true,
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                // attributionBuilder: (_) {
                //   return Text("© OpenStreetMap contributors");
                // },
              ),
            ],
          )),
          // Positioned(
          //     top: MediaQuery.of(context).size.height * 0.5,
          //     left: 0,
          //     right: 0,
          //     child: IgnorePointer(
          //       child: Center(
          //         child: StatefulBuilder(builder: (context, setState) {
          //           return Text(
          //             _searchController.text,
          //             textAlign: TextAlign.center,
          //           );
          //         }),
          //       ),
          //     )),
          Positioned.fill(
              child: IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: widget.locationPinIconColor,
              ),
            ),
          )),
          Positioned(
              bottom: 250,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'btn1',
                backgroundColor: widget.buttonColor,
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom + 1);
                },
                child: Icon(
                  Icons.zoom_in_map,
                  color: widget.buttonTextColor,
                ),
              )),
          Positioned(
              bottom: 185,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'btn2',
                backgroundColor: widget.buttonColor,
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom - 1);
                },
                child: Icon(
                  Icons.zoom_out_map,
                  color: widget.buttonTextColor,
                ),
              )),
          Positioned(
              bottom: 120,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'btn3',
                backgroundColor: widget.buttonColor,
                onPressed: () async {
                  try {
                    LatLng position =
                        await widget.onGetCurrentLocationPressed.call();
                    _mapController.move(
                        LatLng(position.latitude, position.longitude),
                        _mapController.zoom);
                  } catch (e) {
                    _mapController.move(
                        LatLng(widget.center.latitude, widget.center.longitude),
                        _mapController.zoom);
                  } finally {
                    setNameCurrentPos();
                  }
                },
                child: Icon(
                  Icons.my_location,
                  color: widget.buttonTextColor,
                ),
              )),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color.fromARGB(25, 0, 0, 0),
                          blurRadius: 4,
                          spreadRadius: 4,
                          blurStyle: BlurStyle.normal,
                          offset: Offset.fromDirection(pi / 2, 4))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                    child: TextFormField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          border: inputBorder,
                          focusedBorder: inputFocusBorder,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                        onChanged: (String value) {
                          if (_debounce?.isActive ?? false) _debounce?.cancel();

                          _debounce =
                              Timer(const Duration(milliseconds: 500), () async {
                            if (kDebugMode) {
                            }
                            var client = http.Client();
                            try {
                              String url =
                                  'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1&limit=10&importance=1';
                              if (kDebugMode) {
                                print(url);
                              }
                              var response = await client.post(Uri.parse(url));
                              var decodedResponse =
                                  jsonDecode(utf8.decode(response.bodyBytes))
                                      as List<dynamic>;
                              if (kDebugMode) {
                              }
                              //CUSTOM CODE
                              
                              _options = decodedResponse.map((e) {
                                  String final_str= "";
                                  final_str += e["address"].values.toList()[0];
                                  final_str +=", ";
                                  if (e["address"]["road"] != null && e["address"]["road"] != e["address"].values.toList()[0])
                                  {
                                    final_str += e["address"]["road"];
                                    final_str +=", ";

                                  }
                                  if (e["address"]["road"] != null && e["address"]["county"] != null && e["address"]["county"] != e["address"].values.toList()[0]&& e["address"]["county"] != e["address"]["state"])
                                  {
                                    final_str += e["address"]["county"];
                                    final_str +=", ";

                                  }
                                  if (e["address"]["state"] != null && e["address"]["state"] != e["address"].values.toList()[0])
                                  {
                                    final_str += e["address"]["state"];
                                    final_str +=", ";

                                  }
                                   if (e["address"]["country"] != null && e["address"]["country"] != e["address"].values.toList()[0])
                                  {
                                    final_str += e["address"]["country"];
                                    final_str +=", ";
                                  }
                                  if (final_str.substring(final_str.length-2, final_str.length) == ", ")
                                  {
                                    final_str = final_str.substring(0, final_str.length - 2);

                                  }
                                  print("final str: \n");
                                  print(final_str);
                                    return  OSMdata(
                                      displayname: final_str,
                                      lat: double.parse(e['lat']),
                                      lon: double.parse(e['lon']));

                                  }).toList();
                              setState(() {});
                            } finally {
                              client.close();
                            }

                            setState(() {});
                          });
                        }),
                  ),
                  StatefulBuilder(builder: ((context, setState) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length > 5 ? 5 : _options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_options[index].displayname),
                            subtitle: Text(
                                '${_options[index].lat},${_options[index].lon}'),
                            
                            onTap: () {
                              _mapController.move(
                                  LatLng(
                                      _options[index].lat, _options[index].lon),
                                  15.0);

                              _focusNode.unfocus();
                              _options.clear();
                              setState(() {});
                            },
                          );
                        });
                  })),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 55,
                width: 600,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color.fromARGB(25, 0, 0, 0),
                          blurRadius: 4,
                          spreadRadius: 4,
                          blurStyle: BlurStyle.normal,
                          offset: Offset.fromDirection(pi / 2, 4))
                    ],
                    color: widget.buttonColor,
                    borderRadius: BorderRadius.circular(5)),
                child: TextButton(
                  child: Text(
                    widget.buttonText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onPressed: () async {
                    pickData().then((value) {
                      widget.onPicked(value);
                    });
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<PickedData> pickData() async {
    LatLong center = LatLong(
        _mapController.center.latitude, _mapController.center.longitude);
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1&limit=10&importance=1';

    var response = await client.post(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    
    
    String displayName = decodedResponse['display_name'];
    return PickedData(center, displayName);
  }
}

class OSMdata {
  final String displayname;
  final double lat;
  final double lon;
  OSMdata({required this.displayname, required this.lat, required this.lon});
  @override
  String toString() {
    return displayname; //    return '$displayname, $lat, $lon';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, lat, lon);
}

class LatLong {
  final double latitude;
  final double longitude;
  LatLong(this.latitude, this.longitude);
}

class PickedData {
  final LatLong latLong;
  final String address;

  PickedData(this.latLong, this.address);
}

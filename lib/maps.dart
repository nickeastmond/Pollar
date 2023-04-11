import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateMapPage extends StatefulWidget {
  const CreateMapPage({super.key});

  @override
  State<CreateMapPage> createState() => CreateMapPageState();
}

class CreateMapPageState extends State<CreateMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

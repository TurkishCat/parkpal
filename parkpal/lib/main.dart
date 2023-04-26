import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapApp(),
    );
  }
}

class MapApp extends StatefulWidget {
  const MapApp({super.key});

  @override
  State<MapApp> createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  Position? _position;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _getCurrentLocation() async {
    // Get the current location coordinates
    
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _position = position;
    });
  }

  Future<Position> _determinePosition() async {
   
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ParkPal"),
      ),
      body: Center(
        child: _position != null
            ? Text('Current location: ' + _position.toString())
            : Text('No data'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.add),
      ),
    );
  }
}

  









 // FlutterMap(
        //   options: MapOptions(
        //     center: LatLng(49.5, -0.09),
        //     zoom: 10.0,
        //   ),
        //   children: [
        //     TileLayer(
        //       urlTemplate: "https://{s}.tile.openstreetmap.org/{z}{x}{y}.png",
        //       subdomains: const ['a', 'b', 'c'],
        //     ),
        //     MarkerLayer(
        //       markers: [
        //         Marker(
        //           width: 80.0,
        //           height: 80.0,
        //           point: point,
        //           builder: (ctx) => const Icon(
        //             Icons.location_on,
        //             color: Colors.red,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),

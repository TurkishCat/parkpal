import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'classes/street.dart';


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
  Street duboisstraat = Street(
    name: "Duboisstraat",
    lat: 51.229144,
    long: 4.419320,
    parkspaces: 12
  );
  

  final MapController mapController = MapController();

  // final _mapController = osm.MapController(
  //   initPosition: GeoPoint(latitude: 51.228939, longitude: 4.419669),
  //   initMapWithUserPosition: false,
  //   areaLimit: BoundingBox(
  //       north: 51.227703, east: 4.418634, south: 51.230148, west: 4.420742),
  // );

  var markerMap = <String, String>{};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ParkPal"),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(
            51.228939,
            4.419669,
          ), // Set the center of the map to San Francisco
          zoom: 18.0,
          maxZoom: 18.0,
          minZoom: 18.0, // Set the zoom level of the map
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  duboisstraat.lat,
                  duboisstraat.long,
                ), // Set the coordinates of the marker
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    showModal(context);
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 50.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_sharp),
            label: "Session",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: "My Cars",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Account",
          ),
        ],
      ),
    );
  }
}

void showModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Marker clicked'),
        content: const Text('You clicked on the marker'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
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

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
  Street duboisStraat = Street(
    name: "Duboisstraat",
    lat: 51.229144,
    long: 4.419320,
    parkspaces: 12,
  );
  Street langeDijkStraatNoord = Street(
    name: "Lange Dijkstraat PRKNOORD",
    lat: 51.229429,
    long: 4.420216,
    parkspaces: 20,
  );
  Street langeDijkStraatBeneden = Street(
    name: "Lange Dijkstraat Beneden",
    lat: 51.228559,
    long: 4.419395,
    parkspaces: 30,
  );
  Street fuggerStraatNoord = Street(
    name: "Fuggerstraat PRKNOORD",
    lat: 51.229449,
    long: 4.418714,
    parkspaces: 20,
  );
  Street fuggerStraatBeneden = Street(
    name: "Fuggerstraat Beneden",
    lat: 51.228536,
    long: 4.418703,
    parkspaces: 35,
  );
  Street korteDijkStraat = Street(
    name: "Korte Dijkstraat",
    lat: 51.228734,
    long: 4.420575,
    parkspaces: 30,
  );

  List<Street> streets = [];

  final MapController mapController = MapController();

  @override
  void initState() {
    streets = [
      duboisStraat,
      langeDijkStraatBeneden,
      langeDijkStraatNoord,
      fuggerStraatBeneden,
      fuggerStraatNoord,
      korteDijkStraat,
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ParkPal"),
        backgroundColor: Colors.red,
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
          MarkerLayer(markers: _generateMarkers(context, streets)),
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

void _showMarkerModal(BuildContext context, Street street) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Street Name: ${street.name}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Latitude: ${street.lat}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Longitude: ${street.long}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Number of Parking Spaces: ${street.parkspaces}',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<Marker> _generateMarkers(BuildContext context, streets) {
  List<Marker> markers = [];
  for (Street street in streets) {
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(
          street.lat,
          street.long,
        ),
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showMarkerModal(context, street);
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 50.0,
          ),
        ),
      ),
    );
  }
  return markers;
}

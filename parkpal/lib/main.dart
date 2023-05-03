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
import 'package:parkpal/login_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
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
  final MapController mapController = MapController();
  late LatLng _tappedLocation;
  List<Marker> markers = [];
  int _currentIndex = 0;

  void _handleTap(LatLng latLng) {
    setState(() {
      _tappedLocation = latLng;
    });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Do you want to park here?",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                    markers.add(
                      Marker(
                        point: latLng,
                        builder: (context) => Icon(
                          Icons.location_pin,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                    );
                  });
                    Navigator.pop(context);
                  },
                  child: Text("Yes"),
                ),
                SizedBox(height: 10.0),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Handle "No" button pressed
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ParkPal"),
        backgroundColor: Colors.red,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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

   Widget _buildBody() {
    if (_currentIndex == 0) {
      return FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(
            51.228939,
            4.419669,
          ), // Set the center of the map to San Francisco
          zoom: 18.0,
          maxZoom: 18.0,
          minZoom: 18.0, // Set the zoom level of the map
          onTap: (tapPosition, latLng) => {
            _handleTap(latLng),
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers,)
        ],
      );
    } else {
      return Center(
        child: Text('List View'),
      );
    }
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



import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:parkpal/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firebaseinit.dart' as fbInit;
import 'package:parkpal/login_screen.dart';
import './routes.dart';
import 'classes/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  fbInit.initializeFirebase;
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: routes,
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

  getUser(String type) async {
    final User? user = FirebaseAuth.instance.currentUser;

    final DocumentReference<Map<String, dynamic>> userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await userDocRef.get();
    if (type == 'snapshot') {
      return userDocSnapshot;
    }
    if (type == 'ref') {
      return userDocRef;
    }
  }

  void _handleTap(LatLng latLng) {
    final currentUser = getUser('snapshot');

    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<DropdownMenuItem<Car>> dropdownItems =
            currentUser.get().map((car) {
          return DropdownMenuItem<Car>(
            value: car,
            child: Text(car.licensePlate),
          );
        }).toList();

        return Container(
          height: 300.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Do you want to park here?",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: "Start time",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: "End time",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField<Car>(
                  value: dropdownItems.isNotEmpty
                      ? dropdownItems.first.value
                      : null,
                  items: dropdownItems,
                  decoration: const InputDecoration(
                    labelText: "Select car",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    final Car? selectedCar = dropdownItems.isNotEmpty
                        ? dropdownItems.first.value
                        : null;
                    if (selectedCar != null &&
                        startTimeController.text.isNotEmpty &&
                        endTimeController.text.isNotEmpty) {
                      final ParkSpot parkSpot = ParkSpot(
                        latLng: latLng,
                        startTime: startTimeController.text,
                        endTime: endTimeController.text,
                        car: selectedCar,
                      );
                      setState(() async {
                        final DocumentReference<Map<String, dynamic>>
                            userDocRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid);
                        final DocumentSnapshot<Map<String, dynamic>>
                            userDocSnapshot = await userDocRef.get();
                        final List<dynamic> parkSpotsData =
                            getUser('snapshot').get('parkingSpots') ?? [];
                        final List<ParkSpot> parkSpots = parkSpotsData
                            .map((data) => ParkSpot(
                                  latLng: LatLng(
                                      data['latLng'][0], data['latLng'][1]),
                                  startTime: data['startTime'] as String,
                                  endTime: data['endTime'] as String,
                                  car: Car(
                                    model: data['car']['model'] as String,
                                    licensePlate:
                                        data['car']['licensePlate'] as String,
                                  ),
                                ))
                            .toList();
                        parkSpots.add(parkSpot);
                        await userDocRef.update({
                          'parkSpots':
                              parkSpots.map((spot) => spot.toData()).toList()
                        });
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                ),
                const SizedBox(height: 10.0),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
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
    TextEditingController _licensePlateController = TextEditingController();
    TextEditingController _carController = TextEditingController();

    void _addCarModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add a new car',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _licensePlateController,
                      decoration: InputDecoration(
                        hintText: 'License Plate',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _carController,
                      decoration: InputDecoration(
                        hintText: 'Car',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Get the current user
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          // User is not signed in
                          return;
                        }

                        // Create the new car object
                        final Car car = Car(
                          licensePlate: _licensePlateController.text,
                          model: _carController.text,
                        );

                        // Add the new car object to the current user's cars list
                        final DocumentReference<Map<String, dynamic>>
                            userDocRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid);
                        final DocumentSnapshot<Map<String, dynamic>>
                            userDocSnapshot = await userDocRef.get();
                        final List<dynamic> carsData =
                            userDocSnapshot.get('cars') ?? [];
                        final List<Car> cars = carsData
                            .map((data) => Car(
                                licensePlate: data['licensePlate'] as String,
                                model: data['model'] as String))
                            .toList();
                        cars.add(car);
                        await userDocRef.update(
                            {'cars': cars.map((car) => car.toData()).toList()});

                        // Clear the input fields
                        _licensePlateController.clear();
                        _carController.clear();

                        // Close the modal
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

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
          MarkerLayer(
            markers: markers,
          )
        ],
      );
    } else if (_currentIndex == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final carsData = snapshot.data!.get('cars') ?? [];
                final List<dynamic> cars = carsData
                    .map((data) => Car(
                        licensePlate: data['licensePlate'] as String,
                        model: data['model'] as String))
                    .toList();

                if (cars.isEmpty) {
                  return Center(child: Text('You have no cars.'));
                }

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Card(
                      child: ListTile(
                        title: Text(car.licensePlate),
                        subtitle: Text(car.model),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // Delete car from Firebase
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'cars': FieldValue.arrayRemove([
                                {
                                  'licensePlate': car.licensePlate,
                                  'model': car.model
                                }
                              ])
                            });

                            // Remove car from the list
                            setState(() {
                              cars.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                _addCarModal(context);
              },
              child: Text('Add a new car'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.red,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text('List View'),
      );
    }
  }
}

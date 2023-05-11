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
import 'package:parkpal/backend/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend/firebaseinit.dart' as fbInit;
import 'package:parkpal/login/login_screen.dart';
import 'routes/routes.dart';
import 'login/user.dart';
import 'package:easy_debounce/easy_debounce.dart';

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
  List<ParkSpotMarker> markers = [];
  Set<LatLng> _existingMarkerPositions = Set<LatLng>();
  int _currentIndex = 0;

  getUser(String type, String uid) async {
    final User? user = FirebaseAuth.instance.currentUser;

    final DocumentReference<Map<String, dynamic>> userDocRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await userDocRef.get();
    if (type == 'snapshot') {
      return userDocSnapshot;
    }
    if (type == 'ref') {
      return userDocRef;
    }
  }

  void _handleTap(LatLng latLng) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final DocumentReference<Map<String, dynamic>> userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await userDocRef.get();

    final TextEditingController startHourController = TextEditingController();
    final TextEditingController startMinuteController = TextEditingController();
    final TextEditingController endHourController = TextEditingController();
    final TextEditingController endMinuteController = TextEditingController();

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<DropdownMenuItem<Car>> dropdownItems = [];
        if (userDocSnapshot.exists) {
          final List<dynamic> carsData = userDocSnapshot.get('cars') ?? [];
          final List<Car> cars = carsData
              .map((data) => Car(
                    model: data['model'] as String,
                    licensePlate: data['licensePlate'] as String,
                  ))
              .toList();
          dropdownItems.addAll(
            cars.map((car) {
              return DropdownMenuItem<Car>(
                value: car,
                child: Text(car.licensePlate),
              );
            }),
          );
        }

        return Flexible(
          child: Container(
            padding: EdgeInsets.all(16.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: startHourController,
                        decoration: const InputDecoration(
                          labelText: "Start hour",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: TextField(
                        controller: startMinuteController,
                        decoration: const InputDecoration(
                          labelText: "Start minute",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: endHourController,
                        decoration: const InputDecoration(
                          labelText: "End hour",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: TextField(
                        controller: endMinuteController,
                        decoration: const InputDecoration(
                          labelText: "End minute",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Flexible(
                      child: DropdownButtonFormField<Car>(
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
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final Car? selectedCar = dropdownItems.isNotEmpty
                        ? dropdownItems.first.value
                        : null;
                    if (selectedCar != null &&
                        startHourController.text.isNotEmpty &&
                        startMinuteController.text.isNotEmpty &&
                        endHourController.text.isNotEmpty &&
                        endMinuteController.text.isNotEmpty) {
                      final String startTime =
                          "${startHourController.text}:${startMinuteController.text}";
                      final String endTime =
                          "${endHourController.text}:${endMinuteController.text}";
                      final ParkSpot parkSpot = ParkSpot(
                        latLng: latLng,
                        startTime: startTime,
                        endTime: endTime,
                        car: selectedCar,
                      );
                      final DocumentSnapshot<Map<String, dynamic>>
                          userDocSnapshot = await userDocRef.get();
                      final List<dynamic> parkSpotsData =
                          userDocSnapshot.get('parkSpots') ?? [];
                      final List<ParkSpot> parkSpots = parkSpotsData
                          .map((data) => ParkSpot(
                                latLng: LatLng(
                                  data['latLng'][0],
                                  data['latLng'][1],
                                ),
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
                            parkSpots.map((spot) => spot.toData()).toList(),
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Start your parking session."),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
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
      List<ParkSpotMarker> markersToAdd = [];
      EasyDebounce.debounce(
        'my-debouncer',
        const Duration(milliseconds: 1000),
        () {
          FirebaseFirestore.instance.collection('users').get().then(
            (querySnapshot) {
              querySnapshot.docs.forEach(
                (doc) {
                  AppUser user = AppUser.fromSnapshot(doc);
                  print(doc.data()); // Add this line to see the retrieved data

                  user.parkSpots.forEach(
                    (parkSpot) {
                      if (!_existingMarkerPositions.contains(parkSpot.latLng)) {
                        ParkSpotMarker marker = ParkSpotMarker(
                          point: parkSpot.latLng,
                          builder: (BuildContext context) => const Icon(
                            Icons.location_on,                        
                          ),
                          parkSpot: parkSpot,
                        );
                        setState(() {
                          markers.add(marker);
                        });
                      }
                    },
                  );
                },
              );
            },
          );
        },
      );

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
            markers: markers.map((marker) {
              final parkSpot = (marker as ParkSpotMarker).parkSpot;
              return ParkSpotMarker(
                point: parkSpot.latLng,
                builder: (context) => GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Currently Parked Car Info'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Time: ${parkSpot.startTime}'),
                          Text('End Time: ${parkSpot.endTime}'),
                          Text('License Plate: ${parkSpot.car.licensePlate}'),
                        ],
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red.withOpacity(0.8),
                    
                  ),
                ),
                parkSpot: parkSpot,
              );
            }).toList(),
          ),
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

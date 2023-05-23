import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkpal/backend/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend/firebaseinit.dart' as fbInit;
import 'package:parkpal/login/login_screen.dart';
import 'login/user.dart';
import 'package:easy_debounce/easy_debounce.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  fbInit.initializeFirebase;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) =>
            const MapApp(userEmail: ''), // Provide an initial value if needed
      },
    );
  }
}

class MapApp extends StatefulWidget {
  final String userEmail;

  const MapApp({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<MapApp> createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  final MapController mapController = MapController();
  late LatLng _tappedLocation;
  int _currentIndex = 0;
  List<ParkSpotMarker> markers = [];
  Set<LatLng> existingMarkerPositions = {};

  void listenForMarkerUpdates() {
    EasyDebounce.debounce(
      'my-debouncer',
      const Duration(milliseconds: 1000),
      () {
        FirebaseFirestore.instance.collection('users').get().then(
          (querySnapshot) {
            List<ParkSpotMarker> markersToAdd = [];
            List<ParkSpotMarker> updatedMarkers = markers
                .map((marker) => ParkSpotMarker(
                      point: marker.point,
                      builder: marker.builder,
                      parkSpot: marker.parkSpot,
                    ))
                .toList();

            querySnapshot.docs.forEach(
              (doc) {
                final data = doc.data()!;
                final parkSpotsData = data['parkSpots'] as List<dynamic>;
                final userParkSpots = parkSpotsData.map((spotData) {
                  final latLngData = spotData['latLng'] as List<dynamic>;
                  final lat = latLngData[0] as double;
                  final lng = latLngData[1] as double;

                  return ParkSpot(
                    uid: spotData['uid'] as String,
                    latLng: LatLng(lat, lng),
                    endTime: spotData['endTime'] as String,
                    dateTime: DateTime.parse(spotData['dateTime'] as String),
                    car: Car(
                      model: spotData['car']['model'] as String,
                      licensePlate: spotData['car']['licensePlate'] as String,
                    ),
                    email: data['email'] as String,
                  );
                }).toList();

                userParkSpots.forEach(
                  (parkSpot) {
                    DateTime currentTime = DateTime.now();
                    List<String> endTimeParts = parkSpot.endTime.split(':');
                    DateTime endTime = DateTime(
                      parkSpot.dateTime.year,
                      parkSpot.dateTime.month,
                      parkSpot.dateTime.day,
                      int.parse(endTimeParts[0]),
                      int.parse(endTimeParts[1]),
                      0,
                      0,
                      0,
                    );

                    if (currentTime.isAfter(endTime)) {
                      existingMarkerPositions.remove(parkSpot.latLng);
                      updatedMarkers
                          .removeWhere((marker) => marker.parkSpot == parkSpot);
                    } else if (!existingMarkerPositions
                            .contains(parkSpot.latLng) &&
                        endTime.isAfter(DateTime.now())) {
                      ParkSpotMarker marker = ParkSpotMarker(
                        point: parkSpot.latLng,
                        builder: (BuildContext context) => const Icon(
                          Icons.location_on,
                        ),
                        parkSpot: parkSpot,
                      );
                      markersToAdd.add(marker);
                      existingMarkerPositions.add(parkSpot.latLng);
                    }
                  },
                );
              },
            );

            setState(() {
              markers.addAll(markersToAdd);
            });
          },
        );
      },
    );
  }

  void _handleTap(LatLng latLng) async {
    final QuerySnapshot<Map<String, dynamic>> userQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.userEmail)
            .limit(1)
            .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
          userQuerySnapshot.docs.first;

      final TextEditingController endHourController = TextEditingController();
      final TextEditingController endMinuteController = TextEditingController();
      Car? selectedCar;

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

          return SingleChildScrollView(
            child: Container(
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
                          value: selectedCar,
                          items: dropdownItems,
                          decoration: const InputDecoration(
                            labelText: "Select car",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            selectedCar = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedCar != null &&
                          endHourController.text.isNotEmpty &&
                          endMinuteController.text.isNotEmpty) {
                        final String endTime =
                            "${endHourController.text}:${endMinuteController.text}";
                        final CollectionReference<Map<String, dynamic>>
                            parkSpotsCollection =
                            FirebaseFirestore.instance.collection('parkSpots');

                        final DocumentReference<Map<String, dynamic>>
                            newParkSpotRef = parkSpotsCollection.doc();
                        final ParkSpot parkSpot = ParkSpot(
                          uid: newParkSpotRef.id,
                          latLng: latLng,
                          endTime: endTime,
                          dateTime: DateTime.now(),
                          car: selectedCar!,
                          email: widget.userEmail,
                        );
                        newParkSpotRef.set(parkSpot.toData());
                        final List<dynamic> parkSpotsData =
                            userDocSnapshot.get('parkSpots') ?? [];
                        final List<ParkSpot> parkSpots = parkSpotsData
                            .map(
                              (data) => ParkSpot(
                                uid: data['uid'] as String,
                                latLng: LatLng(
                                  data['latLng'][0],
                                  data['latLng'][1],
                                ),
                                endTime: data['endTime'] as String,
                                dateTime:
                                    DateTime.parse(data['dateTime'] as String),
                                car: Car(
                                  model: data['car']['model'] as String,
                                  licensePlate:
                                      data['car']['licensePlate'] as String,
                                ),
                                email: data['email'] as String,
                              ),
                            )
                            .toList();
                        parkSpots.add(parkSpot);
                        await userDocSnapshot.reference.update({
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
  }

  @override
  void initState() {
    print(DateTime.now());
    print("${DateTime.now().hour}:${DateTime.now().minute}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('User email: ${widget.userEmail}');
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

  Future<Widget> _buildBody() async {
    TextEditingController _licensePlateController = TextEditingController();
    TextEditingController _carController = TextEditingController();

    void _addCarModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                        final QuerySnapshot<Map<String, dynamic>>
                            userQuerySnapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: widget.userEmail)
                                .limit(1)
                                .get();

                        if (userQuerySnapshot.docs.isNotEmpty) {
                          final DocumentSnapshot<Map<String, dynamic>>
                              userDocSnapshot = userQuerySnapshot.docs.first;
                          final DocumentReference<Map<String, dynamic>>
                              userDocRef = userDocSnapshot.reference;

                          // Create the new car object
                          final Car car = Car(
                            licensePlate: _licensePlateController.text,
                            model: _carController.text,
                          );

                          // Add the new car object to the current user's cars list
                          final List<dynamic> carsData =
                              userDocSnapshot.get('cars') ?? [];
                          final List<Car> cars = carsData
                              .map((data) => Car(
                                    licensePlate:
                                        data['licensePlate'] as String,
                                    model: data['model'] as String,
                                  ))
                              .toList();
                          cars.add(car);

                          await userDocRef.update({
                            'cars': cars.map((car) => car.toData()).toList()
                          });

                          // Clear the input fields
                          _licensePlateController.clear();
                          _carController.clear();

                          // Close the modal
                          Navigator.pop(context);
                        }
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
      listenForMarkerUpdates();

      final TextEditingController endHourController = TextEditingController();
      final TextEditingController endMinuteController = TextEditingController();
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
              final parkSpot = marker.parkSpot;
              // Retrieve user's cars

              return ParkSpotMarker(
                point: parkSpot.latLng,
                builder: (context) => GestureDetector(
                  onTap: () async {
                    final QuerySnapshot<Map<String, dynamic>>
                        userQuerySnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: widget.userEmail)
                            .limit(1)
                            .get();

                    if (userQuerySnapshot.docs.isNotEmpty) {
                      final DocumentSnapshot<Map<String, dynamic>>
                          userDocSnapshot = userQuerySnapshot.docs.first;

                      if (userDocSnapshot.exists) {
                        final List<dynamic> carsData =
                            userDocSnapshot.get('cars') ?? [];
                        final List<Car> cars = carsData
                            .map((data) => Car(
                                  model: data['model'] as String,
                                  licensePlate: data['licensePlate'] as String,
                                ))
                            .toList();

                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (context) {
                            Car?
                                selectedCar; // Variable to store the selected car
                            return AlertDialog(
                              title: const Text('Currently Parked Car Info'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End Time: ${parkSpot.endTime}'),
                                  Text(
                                      'License Plate: ${parkSpot.car.licensePlate}'),
                                  if (parkSpot.email != widget.userEmail) ...[
                                    SizedBox(height: 20.0),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: DropdownButtonFormField<Car>(
                                            value: selectedCar,
                                            items: cars.map((car) {
                                              return DropdownMenuItem<Car>(
                                                value: car,
                                                child: Text(car.licensePlate),
                                              );
                                            }).toList(),
                                            decoration: const InputDecoration(
                                              labelText: "Select car",
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              selectedCar =
                                                  value; // Update the selected car
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: TextField(
                                            controller: endHourController,
                                            decoration: const InputDecoration(
                                              labelText: "Extend hours",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Flexible(
                                          child: TextField(
                                            controller: endMinuteController,
                                            decoration: const InputDecoration(
                                              labelText: "Extend minutes",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                if (parkSpot.email != widget.userEmail) ...[
                                  ElevatedButton(
                                    onPressed: () async {
                                      final String extendHours =
                                          endHourController.text;
                                      final String extendMinutes =
                                          endMinuteController.text;

                                      // Validate the extension hours and minutes here

                                      if (selectedCar != null &&
                                          extendHours.isNotEmpty &&
                                          extendMinutes.isNotEmpty) {
                                        // Perform the extension logic

                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Extend'),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red.withOpacity(0.6),
                  ),
                ),
                parkSpot: parkSpot,
              );
            }).toList(),
          ),
        ],
      );
    } else if (_currentIndex == 1) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.userEmail)
            .limit(1)
            .snapshots()
            .map((querySnapshot) => querySnapshot.docs.first),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parkSpotsData = snapshot.data!.get('parkSpots') ?? [];
          final List<dynamic> parkSpots = parkSpotsData
              .map((data) => ParkSpot(
                    uid: data['uid'] as String,
                    latLng: LatLng(
                      data['latLng'][0],
                      data['latLng'][1],
                    ),
                    endTime: data['endTime'] as String,
                    dateTime: DateTime.parse(data['dateTime'] as String),
                    car: Car(
                      model: data['car']['model'] as String,
                      licensePlate: data['car']['licensePlate'] as String,
                    ),
                    email: data['email'] as String, // Include the email field
                  ))
              .toList();

          final List<ParkSpot> activeParkSpots = [];
          final List<ParkSpot> expiredParkSpots = [];

          parkSpots.forEach((parkSpot) {
            List<String> endTimeParts = parkSpot.endTime.split(':');
            DateTime endTime = DateTime(
              parkSpot.dateTime.year,
              parkSpot.dateTime.month,
              parkSpot.dateTime.day,
              int.parse(endTimeParts[0]),
              int.parse(endTimeParts[1]),
              0,
              0,
              0,
            );
            if (endTime.isAfter(DateTime.now())) {
              activeParkSpots.add(parkSpot);
            } else {
              expiredParkSpots.add(parkSpot);
            }
          });

          if (parkSpots.isEmpty) {
            return const Center(child: Text('You have no park spots.'));
          }

          return ListView(
            children: [
              const ListTile(
                title: Text('Active Sessions'),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeParkSpots.length,
                itemBuilder: (context, index) {
                  final parkSpot = activeParkSpots[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Car: ${parkSpot.car.model} \nLicenseplate: ${parkSpot.car.licensePlate}'),
                      subtitle: Text(
                        'End Time: ${parkSpot.endTime}\n${parkSpot.dateTime.day}-${parkSpot.dateTime.month}-${parkSpot.dateTime.year}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final QuerySnapshot<Map<String, dynamic>>
                              querySnapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('email', isEqualTo: widget.userEmail)
                                  .limit(1)
                                  .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            final DocumentSnapshot<Map<String, dynamic>>
                                userSnapshot = querySnapshot.docs.first;
                            final List<dynamic> parkSpots =
                                userSnapshot.get('parkSpots') ?? [];

                            parkSpots.removeWhere(
                                (data) => data['uid'] == parkSpot.uid);

                            final DocumentReference<Map<String, dynamic>>
                                userRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userSnapshot.id);

                            await userRef.update({
                              'parkSpots': parkSpots,
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const ListTile(
                title: Text('Expired Sessions'),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expiredParkSpots.length,
                itemBuilder: (context, index) {
                  final parkSpot = expiredParkSpots[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Car: ${parkSpot.car.model} \nLicenseplate: ${parkSpot.car.licensePlate}'),
                      subtitle: Text(
                        'End Time: ${parkSpot.endTime}\n${parkSpot.dateTime.day}-${parkSpot.dateTime.month}-${parkSpot.dateTime.year}',
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else if (_currentIndex == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: widget.userEmail)
                  .limit(1)
                  .snapshots()
                  .map((querySnapshot) => querySnapshot.docs.first),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final carsData = snapshot.data!.get('cars') ?? [];
                final List<dynamic> cars = carsData
                    .map((data) => Car(
                        licensePlate: data['licensePlate'] as String,
                        model: data['model'] as String))
                    .toList();

                if (cars.isEmpty) {
                  return const Center(child: Text('You have no cars.'));
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
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Delete car from Firebase
                            await FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: widget.userEmail)
                                .limit(1)
                                .get()
                                .then((querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                final DocumentSnapshot<Map<String, dynamic>>
                                    userDoc = querySnapshot.docs.first;
                                final DocumentReference<Map<String, dynamic>>
                                    userRef = userDoc.reference;

                                userRef.update({
                                  'cars': FieldValue.arrayRemove([
                                    {
                                      'licensePlate': car.licensePlate,
                                      'model': car.model
                                    }
                                  ])
                                });
                              }
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
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                _addCarModal(context);
              },
              child: const Text('Add a new car'),
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
      return const Center(
        child: Text('List View'),
      );
    }
  }
}

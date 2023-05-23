import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String password; // New field for password
  final List<ParkSpot> parkSpots;
  final List<Car> cars;

  AppUser({
    required this.uid,
    required this.email,
    required this.password, // Add password parameter to the constructor
    this.parkSpots = const [],
    this.cars = const [],
  });

  Map<String, dynamic> toData() {
    final parkSpotsData = parkSpots.map((spot) => spot.toData()).toList();
    final carsData = cars.map((car) => car.toData()).toList();

    return {
      'uid': uid,
      'email': email,
      'password': password, // Include password in the data map
      'parkSpots': parkSpotsData,
      'cars': carsData,
    };
  }

  static AppUser fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final parkSpotsData = data['parkSpots'] as List<dynamic>;
    final carsData = data['cars'] as List<dynamic>;

    final parkSpots = parkSpotsData.map((spotData) {
      final latLngData = spotData['latLng'] as List<dynamic>;
      final lat = latLngData[0] as double;
      final lng = latLngData[1] as double;

      return ParkSpot(
        uid: spotData['uid'] as String,
        latLng: LatLng(lat, lng),
        startTime: spotData['startTime'] as String,
        endTime: spotData['endTime'] as String,
        dateTime: DateTime.parse(
            spotData['dateTime'] as String), // Parse DateTime from string
        car: Car(
          model: spotData['car']['model'] as String,
          licensePlate: spotData['car']['licensePlate'] as String,
        ),
        email: data['email'] as String,
      );
    }).toList();

    final cars = carsData
        .map((carData) => Car(
              model: carData['model'] as String,
              licensePlate: carData['licensePlate'] as String,
            ))
        .toList();

    return AppUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
      password: data['password'] as String, // Assign the password from data
      parkSpots: parkSpots,
      cars: cars,
    );
  }
}


class Car {
  final String model;
  final String licensePlate;

  Car({required this.model, required this.licensePlate});

  Map<String, dynamic> toData() {
    return {
      'model': model,
      'licensePlate': licensePlate,
    };
  }
}

class ParkSpot {
  final String uid;
  final LatLng latLng;
  String? startTime;
  final String endTime;
  final DateTime dateTime;
  final Car car;
  final String email; // New email field

  ParkSpot({
    required this.uid,
    required this.latLng,
    this.startTime,
    required this.endTime,
    required this.dateTime,
    required this.car,
    required this.email, // Added email field to the constructor
  });

  Map<String, dynamic> toData() {
    return {
      'uid': uid,
      'latLng': [latLng.latitude, latLng.longitude],
      'startTime': startTime,
      'endTime': endTime,
      'dateTime': dateTime.toString(), // Convert DateTime to string
      'car': {'model': car.model, 'licensePlate': car.licensePlate},
      'email': email, // Include email field in the data map
    };
  }
}


class ParkSpotMarker extends Marker {
  final ParkSpot parkSpot;

  ParkSpotMarker({
    required this.parkSpot,
    required LatLng point,
    required Widget Function(BuildContext) builder,
  }) : super(point: point, builder: builder);
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AppUser {
  final String uid;
  final String email;
  final List<ParkSpot> parkSpots;
  final List<Car> cars;

  AppUser({
    required this.uid,
    required this.email,
    this.parkSpots = const [],
    this.cars = const [],
  });

  Map<String, dynamic> toData() {
    final parkSpotsData = parkSpots.map((spot) => spot.toData()).toList();
    final carsData = cars.map((car) => car.toData()).toList();

    return {
      'uid': uid,
      'email': email,
      'parkSpots': parkSpotsData,
      'cars': carsData,
    };
  }

  static AppUser fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final parkSpotsData = data['parkSpots'] as List<dynamic>;
    final carsData = data['cars'] as List<dynamic>;

    final parkSpots = parkSpotsData
        .map((spotData) => ParkSpot(
              latLng: spotData['latLng'] as LatLng,
              startTime: spotData['startTime'] as String,
              endTime: spotData['endTime'] as String,
              car: Car(
                model: spotData['car']['model'] as String,
                licensePlate: spotData['car']['licensePlate'] as String,
              ),
            ))
        .toList();

    final cars = carsData
        .map((carData) => Car(
              model: carData['model'] as String,
              licensePlate: carData['licensePlate'] as String,
            ))
        .toList();

    return AppUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
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
  final LatLng latLng;
  final String startTime;
  final String endTime;
  final Car car;

  ParkSpot({
    
    required this.latLng,
    required this.startTime,
    required this.endTime,
    required this.car,
  });

  Map<String, dynamic> toData() {
    return {
      'latLng': [latLng.latitude, latLng.longitude],
      'startTime': startTime,
      'endTime': endTime,
      'car': {
        'model':car.model,
        'licensePlate':car.licensePlate
      },
    };
  }
}

  

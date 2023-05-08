import 'package:flutter/material.dart';
import '../main.dart';
import '../login/login_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (BuildContext context) => const MapApp(),
  '/': (BuildContext context) =>  LoginPage(),
};
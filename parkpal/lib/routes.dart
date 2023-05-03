import 'package:flutter/material.dart';
import 'main.dart';
import 'login_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (BuildContext context) => const MapApp(),
  '/profile': (BuildContext context) => const LoginScreen(),
};
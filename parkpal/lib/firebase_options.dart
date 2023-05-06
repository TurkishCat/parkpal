// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAHv3riEUo6O1oGfU4BGzGoY5NNZ72M8bk',
    appId: '1:1039067180595:web:d87e7365b975ef2291bd46',
    messagingSenderId: '1039067180595',
    projectId: 'parkpal-f1f48',
    authDomain: 'parkpal-f1f48.firebaseapp.com',
    databaseURL: 'https://parkpal-f1f48-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'parkpal-f1f48.appspot.com',
    measurementId: 'G-VHJESFJ0YZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAOKHlTxzoUd32r-u-u8rDuZonaj-2Vq8',
    appId: '1:1039067180595:android:8f6da0e2cb6aa36891bd46',
    messagingSenderId: '1039067180595',
    projectId: 'parkpal-f1f48',
    databaseURL: 'https://parkpal-f1f48-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'parkpal-f1f48.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLOztNVtOr7yV2YBNdkfXTErN3Fa6Zecs',
    appId: '1:1039067180595:ios:c4b4249ffc9b4f5191bd46',
    messagingSenderId: '1039067180595',
    projectId: 'parkpal-f1f48',
    databaseURL: 'https://parkpal-f1f48-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'parkpal-f1f48.appspot.com',
    iosClientId: '1039067180595-rrgv1dgp1vch7glrakk448442j6egb5p.apps.googleusercontent.com',
    iosBundleId: 'com.example.parkpal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLOztNVtOr7yV2YBNdkfXTErN3Fa6Zecs',
    appId: '1:1039067180595:ios:c4b4249ffc9b4f5191bd46',
    messagingSenderId: '1039067180595',
    projectId: 'parkpal-f1f48',
    databaseURL: 'https://parkpal-f1f48-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'parkpal-f1f48.appspot.com',
    iosClientId: '1039067180595-rrgv1dgp1vch7glrakk448442j6egb5p.apps.googleusercontent.com',
    iosBundleId: 'com.example.parkpal',
  );
}

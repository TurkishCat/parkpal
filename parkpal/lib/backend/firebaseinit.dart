import 'package:cloud_firestore/cloud_firestore.dart';

// Initialize Firebase
Future<void> initializeFirebase() async {
  // TODO: Replace with your own Firebase project ID
  final String projectId = 'parkpal-f1f48';

  FirebaseFirestore.instance.settings = Settings(
    host: '$projectId.firebaseio.com',
    sslEnabled: true,
    persistenceEnabled: true,
  );

  // Create a collection reference for AppUser
  final usersCollection = FirebaseFirestore.instance.collection('users');

  if (await usersCollection.doc().get().then((doc) => doc.exists)) {
    print('users collection already exists');
  } else {
    print('creating users collection');
    await usersCollection.doc().set({});
  }
}

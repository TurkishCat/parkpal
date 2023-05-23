import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkpal/main.dart';
import 'package:uuid/uuid.dart';
import './user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailControllerRegistering = TextEditingController();
  final _passwordControllerRegistering = TextEditingController();

  void _login() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();
      final users = query.docs.map((doc) => doc.data()).toList();
      if (users.isNotEmpty) {
        // Encrypt the entered password using SHA-256
        final bytes = utf8.encode(_passwordController.text);
        final digest = sha256.convert(bytes);
        final encryptedPassword = digest.toString();

        // Check if the encrypted password matches the one stored in Firestore
        if (users[0]['password'] == encryptedPassword) {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MapApp(
                      userEmail: users[0]['email'],
                    )),
          );

          print('Invalid email or password.');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _openRegisterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Register'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailControllerRegistering,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordControllerRegistering,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_passwordControllerRegistering.text.isNotEmpty &&
                    _emailControllerRegistering.text.isNotEmpty) {
                  if (_formKey.currentState!.validate()) {
                    _register();
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    try {
      final password = _passwordControllerRegistering.text;

      // Encrypt the password using crypto
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      final encryptedPassword = digest.toString();

      final CollectionReference _userCollection =
          FirebaseFirestore.instance.collection('users');

      String uid = Uuid().v4(); // Generate a unique UID using the Uuid package

      AppUser appUser = AppUser(
        uid: uid,
        email: _emailControllerRegistering.text,
        password: encryptedPassword,
        parkSpots: [],
        cars: [],
      );

      await _userCollection
          .doc(uid)
          .set(appUser.toData()); // Use the generated UID as the document ID

      // Navigate to the home page of your app
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.red,
                    ),
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed:
                        _openRegisterDialog, // call the function to open the dialog
                        style: ElevatedButton.styleFrom(primary: Colors.red,
                    ),
                    child: Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
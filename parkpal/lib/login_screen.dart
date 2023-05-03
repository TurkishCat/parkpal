import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vul alstublieft uw e-mailadres in';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Wachtwoord',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vul alstublieft uw wachtwoord in';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleLoginButtonPress();
                  }
                },
                child: Text('Inloggen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoginButtonPress() {
    final email = emailController.text;
    final password = passwordController.text;

    // TODO: implement your login logic here

    print('Email: $email');
    print('Password: $password');

    // Navigate to the home screen
    Navigator.pushReplacementNamed(context, '/home');
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:csc4360_hw1/pages/new_user.dart';
import 'package:csc4360_hw1/pages/user_signup.dart';
import 'package:csc4360_hw1/pages/user_login.dart';
import 'package:csc4360_hw1/pages/home.dart';

Map<String, Widget Function(BuildContext)> routesList = {
  '/new_user': (context) => NewUser(),
  '/user_signup': (context) => UserSignUp(),
  '/user_login': (context) => UserLogin(),
  '/home': (context) => Home(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FanApp());
}

class FanApp extends StatelessWidget {
  const FanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {

      print('No user already signed in, going to /new_user');

      return MaterialApp(
        routes: routesList,
        initialRoute: '/new_user',
      );

    } else {

      print('User already signed, redirecting to /home');

      return MaterialApp(
        routes: routesList,
        initialRoute: '/home',
      );

    }

  }
}


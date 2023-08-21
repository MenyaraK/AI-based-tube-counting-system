import 'package:flutter/material.dart';
import 'package:loginpage/HomePage.dart';
import 'package:loginpage/Signin.dart';
import 'package:loginpage/Signup.dart';
import 'package:loginpage/Type.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySignupPage(),
    );
  }
}

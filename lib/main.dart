import 'package:flutter/material.dart';
import 'package:flutter_todo/dashboard.dart';
import 'package:flutter_todo/loginpage.dart';
import 'package:flutter_todo/registration.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

void main() async {
  // this will get the token that store in sharedprferences.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString('token'),
  ));
}

class MyApp extends StatelessWidget {
  final token;

  const MyApp({super.key, required this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (JwtDecoder.isExpired(token) == false)
          ? Dashboard(token: token)
          : SignInPage(),
    );
  }
}

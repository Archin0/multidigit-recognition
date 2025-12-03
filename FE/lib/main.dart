import 'package:flutter/material.dart';
import 'page/home.dart';
import 'page/detection.dart';
import 'page/camera.dart';
import 'page/result.dart';
import 'page/history.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi MultiDigit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
      routes: {
        '/detection': (context) => const Detection(),
        '/history': (context) => const History(), // UPDATE INI
        '/camera': (context) => const Camera(),
        '/result': (context) => const Result(),
      },
    );
  }
}

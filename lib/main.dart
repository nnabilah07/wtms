import 'package:flutter/material.dart';
import 'package:wtms/view/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WORKER TASK MANAGEMENT SYSTEM',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

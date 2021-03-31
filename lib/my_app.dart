import 'package:flutter/material.dart';
import 'pages.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.cyan,
        accentColor: Colors.cyanAccent,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context)=> HomePage(),
      },
    );
  }
}

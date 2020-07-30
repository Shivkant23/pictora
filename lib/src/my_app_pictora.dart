import 'package:flutter/material.dart';
import 'package:pictora/src/ui/SplashScreen.dart';
import 'package:pictora/src/ui/home_screen.dart';
import 'package:pictora/src/utils/routes.dart';

class MyAppPictora extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        Routes.homeRoute: (BuildContext context) => HomeScreen(),
        // Routes.detail: (BuildContext context) => DetailsScreen(),
      }
    );
  }
}
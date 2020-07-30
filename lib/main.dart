import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pictora/src/my_app_pictora.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyAppPictora());
}
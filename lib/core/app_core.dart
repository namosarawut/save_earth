import 'package:flutter/material.dart' show GlobalKey, NavigatorState, ScaffoldState;

class SaveEarthCore {
  static GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  static GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>();
  static Map<String, dynamic>? env;
  static Map<String, dynamic>? args;
}

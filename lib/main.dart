import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:save_earth/core/app_core.dart';
import 'package:save_earth/data/data_store.dart';
import 'package:save_earth/firebase_options.dart';
import 'package:save_earth/logic/Bloc/bloc.dart';
import 'package:save_earth/presentation/screens/auth/login_register_screen.dart';
import 'package:save_earth/route/map_routing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำคัญ! ใช้เพื่อให้ Flutter ทำงานกับ async functions ได้
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ตรวจสอบให้แน่ใจว่าไฟล์ firebase_options.dart ถูกสร้างแล้ว
  );

  runApp(EvApp());
}



class EvApp extends StatelessWidget {
  final _routes = evShopRoutes;

  _setUserAgent() async {
    var platform = Platform.isAndroid ? "Android" : "iOS";
    var version = Platform.version;
    var operatingSystemVersion = Platform.operatingSystemVersion;
    String agent = "Mozilla/5.0 (Linux; U; $platform $version) Build/$operatingSystemVersion)";

    DataStore().setArgs({"USER_AGENT": agent});
  }

  Future<bool> _loadEnv() async {
    try {
      const setEnv = String.fromEnvironment('SET_ENV', defaultValue: 'dev');
      String? env = setEnv;
      bool isForE2E = false;
      if (isForE2E) {
        env = 'mock';
      } else {
        env = await rootBundle.loadString('env-local');
      }
      env = env.trim().replaceAll('\n', '');
      await dotenv.load(fileName: 'env/$env');
      DataStore().setEnv(dotenv.env);
      await _setUserAgent();
      log("env : ${env}");
    } catch (e) {
      log(e.toString());
    }

    return true;
  }

  EvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadEnv(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return MultiBlocProvider(
              providers:blocs ,
              child: MaterialApp(
                title: 'Ev Shop',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                routes: _routes,
                initialRoute: 'loginAndRegister',
                navigatorKey: SaveEarthCore.navigatorState,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}




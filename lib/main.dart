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
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/firebase_options.dart';
import 'package:save_earth/logic/Bloc/bloc.dart';
import 'package:save_earth/presentation/screens/auth/login_register_screen.dart';
import 'package:save_earth/repositores/auth_repository.dart';
import 'package:save_earth/route/map_routing.dart';
import 'package:save_earth/service/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final apiService = ApiService();
  final authRepository = AuthRepository(apiService);

  runApp(EvApp(authRepository: authRepository));
}

class EvApp extends StatelessWidget {
  final AuthRepository authRepository;

  EvApp({super.key, required this.authRepository});

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

  /// **ตรวจสอบว่ามี Token และ User หรือไม่**
  Future<String> _checkUserSession() async {
    final token = await LocalStorageHelper.getToken();
    final user = await LocalStorageHelper.getUser();

    if (token != null && user != null) {
      return "/"; // กลับไปที่หน้า Home
    }
    return "loginAndRegister"; // กลับไปหน้า Login/Register
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_loadEnv(), _checkUserSession()]), // ตรวจสอบ Env และ User Session
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            String initialRoute = snapshot.data![1] as String; // ดึงค่าจาก `_checkUserSession()`

            return MultiBlocProvider(
              providers: BlocList(authRepository).blocs,
              child: MaterialApp(
                title: 'save earth',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                routes: _routes,
                initialRoute: initialRoute, // ใช้ค่า initialRoute ที่เช็คมา
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

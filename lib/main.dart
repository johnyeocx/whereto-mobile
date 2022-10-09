import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/pages/main_page.dart';
import 'package:where_to/providers/auth_provider.dart';
import 'package:where_to/providers/clubs_provider.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/services/storage_service.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // FlutterNativeSplash.remove();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => Filters()),
              ChangeNotifierProvider(create: (_) => UserProvider()),
              ChangeNotifierProvider(create: (_) => ClubsProvider()),
              ChangeNotifierProvider(create: (_) => ClubSubmissionsProvider()),
              ChangeNotifierProvider(create: (_) => AuthProvider()),
            ],
            child: const MyApp(),
          )));
}

Future<bool> refreshToken() async {
  StorageService storageService = StorageService();
  var result = await AuthService.refreshTokenRequest();

  if (result == null) {
    return false;
  }

  await storageService.writeSecureData(
      StorageItem(Constants.accessTokenKey, result["newAccessToken"]));

  await storageService.writeSecureData(
      StorageItem(Constants.refreshTokenKey, result["newRefreshToken"]));

  return true;
}

Future<bool> getAccessToken() async {
  StorageService storageService = StorageService();

  String? accessToken =
      await storageService.readSecureData(Constants.accessTokenKey);

  if (accessToken == null || Jwt.isExpired(accessToken)) {
    bool res = await refreshToken();
    return res;
  }

  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // home: MainPage(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => MainPage(),
      },
    );
  }
}

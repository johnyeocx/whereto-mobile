import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';

import 'package:where_to/misc/constants.dart';
import 'package:where_to/pages/auth/login.dart';
import 'package:where_to/pages/home/home_page.dart';
import 'package:where_to/providers/auth_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import '../services/storage_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoggedIn = false;
  final StorageService _storageService = StorageService();

  void setIsLoggedIn(bool isLoggedIn) {
    setState(() => _isLoggedIn = isLoggedIn);
  }

  @override
  void initState() {
    getAccessToken();
    super.initState();
  }

  Future<bool> refreshToken() async {
    var result = await AuthService.refreshTokenRequest();

    if (result == null) {
      setState(() {
        _isLoggedIn = false;
      });
      return false;
    }

    await _storageService.writeSecureData(
        StorageItem(Constants.accessTokenKey, result["newAccessToken"]));

    await _storageService.writeSecureData(
        StorageItem(Constants.refreshTokenKey, result["newRefreshToken"]));

    return true;
  }

  Future<void> getAccessToken() async {
    String? accessToken =
        await _storageService.readSecureData(Constants.accessTokenKey);

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      bool success = await refreshToken();
      if (!success) {
        await deleteKeys();
        FlutterNativeSplash.remove();
        return;
      }
    }

    final userModel = Provider.of<UserProvider>(context, listen: false);
    final userSuccess = await userModel.setUser();
    if (!userSuccess) {
      await deleteKeys();
      FlutterNativeSplash.remove();
      return;
    }

    context.read<AuthProvider>().toggleIsLoggedIn(true);
    FlutterNativeSplash.remove();
    return;
  }

  Future<void> deleteKeys() async {
    await _storageService.deleteSecureData(Constants.accessTokenKey);
    await _storageService.deleteSecureData(Constants.refreshTokenKey);
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isLoggedIn) {
      return HomePage(setIsLoggedIn: setIsLoggedIn);
    } else {
      return LoginPage(setIsLoggedIn: setIsLoggedIn);
    }
  }
}

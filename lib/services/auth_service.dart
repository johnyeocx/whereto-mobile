import 'package:jwt_decode/jwt_decode.dart';
import 'package:where_to/misc/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:where_to/services/storage_service.dart';

class AuthService {
  static final _storageService = StorageService();

  // LOGIN
  static Future<Map> loginRequest(String userDetail, String password) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/auth/login");

    Map reqBody = {'user_detail': userDetail, 'password': password};
    var body = json.encode(reqBody);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 204) {
      return {"error": 1, "message": "User not found"};
    } else if (response.statusCode == 401) {
      return {"error": 2, "message": "Password incorrect"};
    } else if (response.statusCode != 200) {
      return {"error": 3, "message": "error"};
    }

    var res = json.decode(response.body);
    return res;
  }

  // SIGNUP
  static Future<Map> signupRequest(
      String username, String email, String password) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/auth/signup");
    Map reqBody = {'username': username, 'email': email, 'password': password};
    var body = json.encode(reqBody);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    // Map<String,
    var res = json.decode(response.body);
    if (response.statusCode != 200) {
      String error = res;

      if (error == "email exists") {
        return {
          "error": {0: "Email already exists"}
        };
      } else if (error == "username exists") {
        return {
          "error": {1: "Username already exists"}
        };
      }
    }

    return res;
  }

  static Future<Map?> refreshTokenRequest() async {
    var refreshToken =
        await _storageService.readSecureData(Constants.refreshTokenKey);

    if (refreshToken == null) {
      return null;
    }

    var url = Uri.parse("${Constants.serverEndpoint}/api/auth/refresh");

    Map reqBody = {'refresh_token': refreshToken};
    var body = json.encode(reqBody);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode != 200) {
      return null;
    } else {
      var res = json.decode(response.body);
      return res;
    }
  }

  // GET RESET EMAIL REQUEST
  // SIGNUP
  static Future<Map<dynamic, dynamic>?> getResetEmailRequest(
      String email) async {
    // var url = Uri.http("localhost:8080", 'api/auth/signup');
    var url = Uri.parse(
        "${Constants.serverEndpoint}/api/auth/generate_reset?email=$email");

    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        return {
          "error": {0: "Email doesn't exist"}
        };
      }
    }

    return null;
  }

  static Future<Map<String, String>> getAuthHeader() async {
    String? accessToken =
        await _storageService.readSecureData(Constants.accessTokenKey);

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      Map<dynamic, dynamic>? res = await refreshTokenRequest();

      if (res == null) {
        return {};
      } else {
        await _storageService.writeSecureData(
            StorageItem(Constants.accessTokenKey, res["newAccessToken"]));
        await _storageService.writeSecureData(
            StorageItem(Constants.refreshTokenKey, res["newRefreshToken"]));
        return {"Authorization": "BEARER ${res["newAccessToken"]}"};
      }
    } else {
      return {"Authorization": "BEARER $accessToken"};
    }
  }
}

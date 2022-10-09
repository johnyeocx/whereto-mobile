import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/models/user.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserRequest() async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/self");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var response = await http.get(url, headers: authHeader);

    print(response);
    if (response.statusCode != 200) {
      return null;
    }
    var res = json.decode(response.body);

    User user = User.fromJson(res["user"]);
    Map<String, bool> userLikes = {};
    if (res["user_likes"] != null) {
      for (int i = 0; i < res["user_likes"].length; i++) {
        String clubId = res["user_likes"][i]["club_id"];
        userLikes[clubId] = true;
      }
    }

    return {
      "user": user,
      "user_likes": userLikes,
      "user_friendships": res["user_friendships"],
      "user_plan": res["user_plan"]
    };
  }

  // static Future<bool>

  static Future<bool> addFriendRequest(String receipientID) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/add");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var resBody = json.encode({"receipient_id": receipientID});

    var res = await http.post(url, body: resBody, headers: authHeader);
    return res.statusCode == 200;
  }

  static Future<bool> removeFriendRequest(String receipientID) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/remove");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var resBody = json.encode({"receipient_id": receipientID});
    var res = await http.post(url, body: resBody, headers: authHeader);
    return res.statusCode == 200;
  }

  static Future<Plan?> getFriendPlanRequest(String receipientID) async {
    var url =
        Uri.parse("${Constants.serverEndpoint}/api/user/plan?id=$receipientID");
    Map<String, String> authHeader = await AuthService.getAuthHeader();

    var res = await http.get(url, headers: authHeader);
    if (res.statusCode != 200) return null;
    var resBody = json.decode(res.body);
    return Plan.fromJson(resBody);
  }

  static Future<Map<String, dynamic>?> getUserFullFriendsReq() async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/friends/full");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var response = await http.get(url, headers: authHeader);

    if (response.statusCode != 200) {
      return null;
    }

    var res = json.decode(response.body);

    Map<String, Plan> planMap = {};

    for (int i = 0; i < res["friend_plans"].length; i++) {
      Map<String, dynamic> plan = res["friend_plans"][i];
      planMap[plan["user_id"]] = Plan.fromJson(plan);
    }

    return {
      "friends": res["friends"],
      "friend_plans": planMap,
    };
  }

  static Future<List<dynamic>?> getUserInwardFriendsReq() async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/friends/inwards");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var response = await http.get(url, headers: authHeader);

    if (response.statusCode != 200) {
      return null;
    }

    var res = json.decode(response.body);

    return res;
  }

  static Future<List<dynamic>?> getUserOutwardFriendsReq() async {
    var url =
        Uri.parse("${Constants.serverEndpoint}/api/user/friends/outwards");
    Map<String, String> authHeader = await AuthService.getAuthHeader();
    var response = await http.get(url, headers: authHeader);

    if (response.statusCode != 200) {
      return null;
    }

    var res = json.decode(response.body);

    return res;
  }

  static Future<int> changeUsernameRequest(String newUsername) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/change_username");
    Map<String, String> authHeader = await AuthService.getAuthHeader();

    var resBody = json.encode({"new_username": newUsername});

    var res = await http.patch(url, body: resBody, headers: authHeader);

    return res.statusCode;
  }

  static Future<int> changePasswordRequest(
      String oldPassword, String newPassword) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/user/change_password");
    Map<String, String> authHeader = await AuthService.getAuthHeader();

    var resBody = json.encode({
      "old_password": oldPassword,
      "new_password": newPassword,
    });

    var res = await http.patch(url, body: resBody, headers: authHeader);

    return res.statusCode;
  }
}

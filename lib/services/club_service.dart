import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:where_to/misc/constants.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/models/submissions.dart';
import 'package:where_to/services/auth_service.dart';
import '../models/club.dart';
import '../providers/filters_provider.dart';

class ClubService {
  static Future<List<Club>?> getClubsRequest(
      int filterOption, Position userPos, bool likedOnly) async {
    var url = Uri.parse(
        "${Constants.serverEndpoint}/api/clubs?filter=$filterOption&longitude=${userPos.longitude}&latitude=${userPos.latitude}${likedOnly ? "&liked_only=true" : ""}");

    var authHeader = await AuthService.getAuthHeader();
    var res = await http.get(url, headers: authHeader);

    if (res.statusCode != 200) {
      log("Failed to make get clubs request");
      return null;
    }

    List<Club> clubs = [];

    var resBody = json.decode(res.body);

    for (int i = 0; i < resBody.length; i++) {
      clubs.add(Club.fromJson(resBody[i]));
    }

    return clubs;
  }

  static Future<Map<FilterBy, List<Submission>>?> getClubSubmissionsReq(
      String clubId) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/club/$clubId");

    var res = await http.get(url);

    if (res.statusCode != 200) {
      var resBody = json.decode(res.body);
      print(resBody);
      log("Failed to make get clubs request");
      return null;
    }

    var resBody = json.decode(res.body);

    Map<FilterBy, List<Submission>> clubSubmissions = {};
    for (int i = 0; i < 4; i++) {
      clubSubmissions[FilterBy.values[i + 1]] = List<Submission>.from(
          resBody[i].map((model) => Submission.fromJson(model)));
    }

    return clubSubmissions;
  }

  static Future<dynamic> getUserVotesReq(String clubId) async {
    var url = Uri.parse("${Constants.serverEndpoint}/api/club/votes/$clubId");
    var authHeader = await AuthService.getAuthHeader();
    var res = await http.get(url, headers: authHeader);

    if (res.statusCode != 200) {
      var resBody = json.decode(res.body);

      log("Failed to make get clubs request");
      return null;
    }

    var resBody = json.decode(res.body);

    return resBody;
  }

  static Future<bool> likeClubReq(String clubId, bool liking) async {
    Uri url;
    if (liking) {
      url = Uri.parse("${Constants.serverEndpoint}/api/club/like");
    } else {
      url = Uri.parse("${Constants.serverEndpoint}/api/club/unlike");
    }

    var authHeader = await AuthService.getAuthHeader();

    var res = await http.post(url,
        body: json.encode({
          "club_id": clubId,
        }),
        headers: authHeader);

    if (res.statusCode != 200) {
      return false;
    }

    return true;
  }

  static Future<Plan?> goingClubReq(
      String clubId, DateTime start, DateTime end) async {
    Uri url = Uri.parse("${Constants.serverEndpoint}/api/club/plan");
    var authHeader = await AuthService.getAuthHeader();

    var reqBody = {
      "club_id": clubId,
      "start": start.millisecondsSinceEpoch,
      "end": end.millisecondsSinceEpoch,
    };

    var res =
        await http.post(url, body: json.encode(reqBody), headers: authHeader);

    if (res.statusCode != 200) {
      return null;
    }

    var resDecoded = json.decode(res.body);
    return Plan.fromJson(resDecoded);
  }

  static Future<Plan?> cancelPlanReq(String clubId) async {
    Uri url = Uri.parse("${Constants.serverEndpoint}/api/club/plan/remove");
    var authHeader = await AuthService.getAuthHeader();

    var reqBody = {
      "club_id": clubId,
    };

    var res =
        await http.delete(url, body: json.encode(reqBody), headers: authHeader);

    if (res.statusCode != 200) {
      return null;
    }

    var resDecoded = json.decode(res.body);
    return Plan.fromJson(resDecoded);
  }

  static Future<List?> getFriendsGoingReq(String clubId) async {
    Uri url = Uri.parse(
        "${Constants.serverEndpoint}/api/club/friends/?clubId=$clubId");
    var authHeader = await AuthService.getAuthHeader();

    var res = await http.get(url, headers: authHeader);

    if (res.statusCode != 200) {
      return null;
    }

    var resDecoded = json.decode(res.body);
    return resDecoded;
  }
}

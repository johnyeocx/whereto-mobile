import 'package:flutter/material.dart';
import 'package:where_to/services/club_service.dart';

import '../models/submissions.dart';
import 'filters_provider.dart';

class ClubSubmissionsProvider with ChangeNotifier {
  Map<FilterBy, List<Submission>>? _clubSubmissions;
  Map<FilterBy, String>? _voted;
  List<dynamic> _friendsGoing = [];
  bool _loading = true;

  Map<FilterBy, List<Submission>>? get clubSubmissions => _clubSubmissions;
  Map<FilterBy, String>? get voted => _voted;
  List<dynamic> get friendsGoing => _friendsGoing;
  bool get loading => _loading;

  Future<dynamic> setClubSubmissions(String clubId) async {
    _loading = true;
    notifyListeners();

    _clubSubmissions = await ClubService.getClubSubmissionsReq(clubId);
    if (_clubSubmissions == null) return;
    _loading = false;
    notifyListeners();
  }

  Future<dynamic> setVotedSubmissions(String clubId) async {
    _voted = {
      FilterBy.queueTime: "",
      FilterBy.currentGenre: "",
      FilterBy.energyLevels: "",
      FilterBy.ratio: "",
    };

    var res = await ClubService.getUserVotesReq(clubId);
    if (res != null) {
      _voted = {
        FilterBy.queueTime: res["queue_time"] ?? "",
        FilterBy.currentGenre: res["current_genre"] ?? "",
        FilterBy.energyLevels: res["energy_level"] ?? "",
        FilterBy.ratio: res["ratio"] ?? "",
      };
    }

    notifyListeners();
  }

  Future<void> setFriendsGoing(String clubId) async {
    List<dynamic>? res = await ClubService.getFriendsGoingReq(clubId);
    if (res != null) {
      _friendsGoing = res;
    }

    notifyListeners();
    return;
  }

  addClubSubmission(dynamic msg) {
    FilterBy index = FilterBy.values[msg["stat"]];
    _clubSubmissions?[index]?.add(Submission.fromJson(msg["data"]));
    notifyListeners();
  }

  dynamic handleVoteMsg(dynamic msg, String userID) {
    if (_voted == null || _clubSubmissions == null) return;

    FilterBy index = FilterBy.values[msg["stat"]];
    // set voted
    if (msg["sender_id"] == userID) {
      _voted![index] = msg["voted"];
    }

    // increment vote count
    List<Submission> submissions = _clubSubmissions![index]!;

    int? incStart;
    if (msg["inc"] != null) {
      for (int i = 0; i < submissions.length; i++) {
        if (submissions[i].id == msg["inc"]) {
          submissions[i].votes++;
          incStart = i;
          break;
        }
      }
    }

    int? decStart;
    if (msg["dec"] != null) {
      for (int i = 0; i < submissions.length; i++) {
        if (submissions[i].id == msg["dec"]) {
          submissions[i].votes -= 1;
          decStart = i;
          break;
        }
      }
    }

    if (incStart != null &&
        (incStart == 0 ||
            submissions[incStart].votes < submissions[incStart - 1].votes ||
            (submissions[incStart].votes == submissions[incStart - 1].votes &&
                submissions[incStart]
                    .timestamp
                    .isBefore(submissions[incStart - 1].timestamp)))) {
      incStart = null;
    }

    if (decStart != null &&
        (decStart == submissions.length - 1 ||
            submissions[decStart].votes > submissions[decStart + 1].votes ||
            (submissions[decStart].votes == submissions[decStart + 1].votes &&
                submissions[decStart]
                    .timestamp
                    .isAfter(submissions[decStart + 1].timestamp)))) {
      decStart = null;
    }

    notifyListeners();

    return {"incStart": incStart, "decStart": decStart};
  }

  int reorderIncreasedVote(int startIndex, int stat) {
    if (_clubSubmissions == null) return -1;

    List<Submission> submissions = _clubSubmissions![FilterBy.values[stat]]!;

    int endIndex = startIndex;
    for (int i = startIndex; i > 0; i--) {
      if (submissions[i].votes > submissions[i - 1].votes ||
          (submissions[i].votes == submissions[i - 1].votes &&
              submissions[i].timestamp.isAfter(submissions[i - 1].timestamp))) {
        dynamic tmp = submissions[i];
        submissions[i] = submissions[i - 1];
        submissions[i - 1] = tmp;
        endIndex = i - 1;
      } else {
        break;
      }
    }
    notifyListeners();
    return endIndex;
  }

  int reorderDecreasedVote(int startIndex, int stat) {
    if (_clubSubmissions == null) return -1;

    List<Submission> submissions = _clubSubmissions![FilterBy.values[stat]]!;
    int endIndex = startIndex;
    for (int i = startIndex; i < submissions.length - 1; i++) {
      if (submissions[i].votes < submissions[i + 1].votes ||
          (submissions[i].votes == submissions[i + 1].votes &&
              submissions[i]
                  .timestamp
                  .isBefore(submissions[i + 1].timestamp))) {
        dynamic tmp = submissions[i];
        submissions[i] = submissions[i + 1];
        submissions[i + 1] = tmp;
        endIndex = i + 1;
      } else {
        break;
      }
    }
    notifyListeners();
    return endIndex;
  }

  int? handleUnvoteMsg(dynamic msg, String userID) {
    if (_voted == null || _clubSubmissions == null) return -1;

    FilterBy index = FilterBy.values[msg["stat"]];
    // set voted
    if (msg["sender_id"] == userID) {
      _voted![index] = "";
    }

    // increment vote count
    List<Submission> submissions = _clubSubmissions![index]!;

    int? decStart;
    if (msg["dec"] != null) {
      for (int i = 0; i < submissions.length; i++) {
        if (submissions[i].id == msg["dec"]) {
          submissions[i].votes -= 1;
          decStart = i;
          break;
        }
      }
    }

    notifyListeners();

    if (decStart != null &&
        (decStart == submissions.length - 1 ||
            submissions[decStart].votes >= submissions[decStart + 1].votes)) {
      decStart = null;
    }
    return decStart;
    // decrement vote count
  }
}

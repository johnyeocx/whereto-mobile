import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:where_to/services/club_service.dart';

import '../models/club.dart';

class ClubsProvider with ChangeNotifier {
  List<Club>? _clubs;
  bool loading = true;

  List<Club>? get clubs => _clubs;

  Future<List<Club>?> setClubs(
      int filterOption, Position userLocation, bool likedOnly) async {
    loading = true;
    _clubs = (await ClubService.getClubsRequest(
        filterOption, userLocation, likedOnly));

    if (_clubs == null) return null;

    loading = false;
    notifyListeners();
    return _clubs;
  }

  void updateClubStat(dynamic msg) {
    if (_clubs == null) {
      return;
    }

    for (int i = 0; i < _clubs!.length; i++) {
      if (_clubs![i].id == msg["club_id"]) {
        ClubStat updatedStat = ClubStat(
            timestamp: msg["timestamp"],
            submissionID: msg["submission_id"],
            value: msg["value"]);

        if (msg["stat"] == 1) {
          _clubs![i].currentStats.queueTime = updatedStat;
        } else if (msg["stat"] == 2) {
          _clubs![i].currentStats.currentGenre = updatedStat;
        } else if (msg["stat"] == 3) {
          _clubs![i].currentStats.energyLevel = updatedStat;
        } else if (msg["stat"] == 4) {
          _clubs![i].currentStats.ratio = updatedStat;
        }

        break;
      }
    }

    notifyListeners();
  }

  void setClubIsOpen(String clubId, bool value) {
    if (_clubs == null) return;
    for (int i = 0; i < _clubs!.length; i++) {
      if (_clubs![i].id == clubId) {
        if (_clubs![i].IsOpen == value) {
          return;
        } else {
          _clubs![i].IsOpen = value;
          notifyListeners();
          return;
        }
      }
    }
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/services/user_service.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, bool> _likedClubs = {};
  UserFriendships? _userFriendships;
  Plan? _userPlan;
  bool loading = false;

  User? get user => _user;
  Map<String, bool> get likedClubs => _likedClubs;
  UserFriendships? get userFriendships => _userFriendships;
  Plan? get userPlan => _userPlan;

  Future<bool> setUser() async {
    // loading = true;

    Map<String, dynamic>? userRes = await UserService.getUserRequest();

    if (userRes == null) return false;

    _user = userRes["user"] as User;
    _likedClubs = userRes["user_likes"];
    _userFriendships = UserFriendships.fromJson(userRes["user_friendships"]);

    if (userRes["user_plan"] != null) {
      _userPlan = Plan.fromJson(userRes["user_plan"]);
    } else {
      _userPlan = null;
    }

    _user?.location = await _getUserLocation();

    loading = false;
    notifyListeners();
    return true;
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("Location services are disabled");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      print("Location permissions are denied");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var userPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest);

    return userPos;
  }

  void likeClub(String clubId) {
    _likedClubs[clubId] = true;
    notifyListeners();
  }

  void unlikeClub(String clubId) {
    _likedClubs[clubId] = false;
    notifyListeners();
  }

  void addFriend(String userId, FriendshipStatus status) {
    if (status == FriendshipStatus.inwards) {
      _userFriendships?.inwards.remove(userId);
      _userFriendships?.full.add(userId);
    } else if (status == FriendshipStatus.none) {
      _userFriendships?.outwards.add(userId);
    }
    notifyListeners();
  }

  void removeFriend(String userId, FriendshipStatus status) {
    if (status == FriendshipStatus.full) {
      _userFriendships?.full.remove(userId);
      _userFriendships?.inwards.add(userId);
    } else if (status == FriendshipStatus.outwards) {
      _userFriendships?.outwards.remove(userId);
    }
    notifyListeners();
  }

  void setUserPlan(Plan? newPlan) {
    _userPlan = newPlan;
    notifyListeners();
  }

  void setUsername(String newUsername) {
    if (_user == null) {
      return;
    }

    _user!.username = newUsername;
    notifyListeners();
    return;
  }
}

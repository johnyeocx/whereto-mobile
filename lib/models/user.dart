import 'package:geolocator/geolocator.dart';
import 'package:objectid/objectid.dart';

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({required this.latitude, required this.longitude});
}

class User {
  final String userID;
  String username;
  final String email;
  late final Position? location;

  User({
    required this.userID,
    required this.username,
    required this.email,
    this.location,
  });

  User.fromJson(Map<String, dynamic> json)
      : userID = json['id'],
        username = json['username'],
        email = json["email"];
}

enum FriendshipStatus { full, inwards, outwards, none }

class UserFriendships {
  String id;
  String ownerID;
  List<dynamic> full;
  List<dynamic> inwards;
  List<dynamic> outwards;

  UserFriendships.fromJson(Map<String, dynamic> friendships)
      : id = friendships["id"],
        ownerID = friendships["owner_id"],
        full = friendships["full"],
        inwards = friendships["inwards"],
        outwards = friendships["outwards"];
}

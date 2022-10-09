import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart';

class ClubStat {
  final String timestamp;
  final String submissionID;
  final dynamic value;

  ClubStat(
      {required this.timestamp,
      required this.submissionID,
      required this.value});
}

class ClubStats {
  ClubStat? queueTime;
  ClubStat? currentGenre;
  ClubStat? energyLevel;
  ClubStat? ratio;

  ClubStats(
      {required this.queueTime,
      required this.currentGenre,
      required this.energyLevel,
      required this.ratio});
}

class Club {
  final String id;
  final String name;
  final String address;
  final String countryCode;

  final List<dynamic> schedule;
  final int timezoneOffset;
  final List<double> coordinates;

  final ClubStats currentStats;
  final int likesCount;
  bool IsOpen;

  Club(
      {required this.id,
      required this.name,
      required this.address,
      required this.countryCode,
      required this.schedule,
      required this.timezoneOffset,
      required this.coordinates,
      required this.currentStats,
      required this.likesCount,
      required this.IsOpen});

  Club.fromJson(Map<String, dynamic> club)
      : id = club['id'],
        name = club['name'],
        address = club['address'],
        countryCode = club['country_code'],
        timezoneOffset = club['timezone_offset'],
        schedule = club['schedule'],
        coordinates = [
          club['location']['coordinates'][0],
          club['location']['coordinates'][1]
        ],
        likesCount = club['likes_count'],
        IsOpen = club["sortPriority"] != 2,
        currentStats = ClubStats(
          queueTime: club["current_stats"]["queue_time"] != null
              ? ClubStat(
                  timestamp: club["current_stats"]["queue_time"]["vote_id"],
                  submissionID: club["current_stats"]["queue_time"]["vote_id"],
                  value: club["current_stats"]["queue_time"]["value"],
                )
              : null,
          currentGenre: club["current_stats"]["current_genre"] != null
              ? ClubStat(
                  timestamp: club["current_stats"]["current_genre"]["vote_id"],
                  submissionID: club["current_stats"]["current_genre"]
                      ["vote_id"],
                  value: club["current_stats"]["current_genre"]["value"],
                )
              : null,
          energyLevel: club["current_stats"]["energy_level"] != null
              ? ClubStat(
                  timestamp: club["current_stats"]["energy_level"]["vote_id"],
                  submissionID: club["current_stats"]["energy_level"]
                      ["vote_id"],
                  value: club["current_stats"]["energy_level"]["value"],
                )
              : null,
          ratio: club["current_stats"]["ratio"] != null
              ? ClubStat(
                  timestamp: club["current_stats"]["ratio"]["vote_id"],
                  submissionID: club["current_stats"]["ratio"]["vote_id"],
                  value: club["current_stats"]["ratio"]["value"],
                )
              : null,
        );

  String image() {
    String imageName = name.replaceAll(' ', '-').toLowerCase();
    // print(imageName);
    String imageEndpoint =
        "https://whereto.s3.ap-southeast-1.amazonaws.com/clubs";
    return "$imageEndpoint/$imageName-${countryCode.toLowerCase()}"; // change
  }

  bool isOpen() {
    return IsOpen;
    // DateTime utcNow = DateTime.now().toUtc();
    // DateTime startOfDay = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);

    // var utcOffset = utcNow.difference(startOfDay).inMinutes;
    // var today = utcNow.weekday;

    // int localOffset = utcOffset + timezoneOffset * 60;
    // if (localOffset >= 1440) {
    //   localOffset -= 1440;
    //   today += 1;
    // } else if (localOffset < 0) {
    //   localOffset = 1440 - localOffset;
    //   today -= 1;
    // }

    // int ytdOffset = localOffset + 1440;
    // int ytd = (today - 1) % 7;

    // bool isOpen = schedule[ytd] != null &&
    //     ytdOffset >= schedule[ytd][0] &&
    //     ytdOffset <= schedule[ytd][1];

    // int tdy = today % 7;
    // if (!isOpen) {
    //   isOpen = schedule[tdy] != null &&
    //       localOffset >= schedule[tdy][0] &&
    //       localOffset <= schedule[tdy][1];
    // }

    // return isOpen;
  }

  opensAt() {
    DateTime utcNow = DateTime.now().toUtc();
    DateTime startOfDay = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
    var utcOffset = utcNow.difference(startOfDay).inMinutes;

    int today = utcNow.weekday;
    int localOffset = utcOffset + timezoneOffset;

    if (localOffset >= 1440) {
      localOffset -= 1440;
      today += 1;
    } else if (localOffset < 0) {
      localOffset = 1440 - localOffset;
      today -= 1;
    }
  }

  List<DateTime>? getStartAndEnd() {
    // var tz = TimeZone(8 * 60 * 60 * 1000, isDst: false, abbreviation: "UTC+8");

    DateTime utcNow = DateTime.now().toUtc();
    DateTime localNow = utcNow.add(Duration(hours: timezoneOffset));

    DateTime startOfTdy =
        DateTime.utc(localNow.year, localNow.month, localNow.day);
    DateTime startOfYtd = startOfTdy.subtract(const Duration(hours: 24));

    int ytd = startOfYtd.weekday % 7;
    if (schedule[ytd] != null) {
      int startOffset = schedule[ytd][0];
      int endOffset = schedule[ytd][1];
      DateTime start = startOfYtd.add(Duration(minutes: startOffset));
      DateTime end = startOfYtd.add(Duration(minutes: endOffset));

      if (localNow.isAfter(start) && localNow.isBefore(end)) {
        return [start, end];
      }
    }

    if (schedule[startOfTdy.weekday] != null) {
      int startOffset = schedule[startOfTdy.weekday][0];
      int endOffset = schedule[startOfTdy.weekday][1];

      DateTime start = startOfTdy.add(Duration(minutes: startOffset));
      DateTime end = startOfTdy.add(Duration(minutes: endOffset));

      if (localNow.isAfter(start) && localNow.isBefore(end)) {
        return [start, end];
      }
    }

    return null;
  }
}

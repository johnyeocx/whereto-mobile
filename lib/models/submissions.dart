import 'package:where_to/misc/utils.dart';
import 'package:where_to/providers/filters_provider.dart';

class Submission {
  final String id;
  final DateTime timestamp;
  final String clubID;
  final String senderID;
  final dynamic value;
  // final int stat;
  final String username;
  int votes;

  Submission(
      {required this.id,
      required this.timestamp,
      required this.clubID,
      required this.senderID,
      required this.value,
      required this.username,
      required this.votes});

  Submission.fromJson(Map<String, dynamic> sub)
      : id = sub["id"],
        timestamp = Utils.getFormattedDateFromFormattedString(
            value: sub["timestamp"], isUtc: true),
        clubID = sub["metadata"]["club_id"],
        senderID = sub["metadata"]["sender_id"],
        value = sub["value"],
        username = sub["username"],
        votes = sub["votes"];
}

// class ClubSubmissions {
//   // final List<dynamic> queueTimes;
//   // final List<dynamic> currentGenres;
//   // final List<dynamic> energyLevels;
//   // final List<dynamic> ratios;

//   ClubSubmissions(
//       {required this.queueTimes,
//       required this.currentGenres,
//       required this.energyLevels,
//       required this.ratios});

//   ClubSubmissions.fromJson(Map<String, dynamic> clubSubmissions)
//       : queueTimes = clubSubmissions['queue_times'],
//         currentGenres = clubSubmissions['current_genres'],
//         energyLevels = clubSubmissions['energy_levels'],
//         ratios = clubSubmissions['ratios'];
// }

class VotedSubmissions {
  final Map<FilterBy, String> voted;

  VotedSubmissions({required this.voted});
}

import 'package:where_to/misc/utils.dart';

class Plan {
  final String planID;
  final String clubID;
  final String clubName;
  final String userID;
  final DateTime start;
  final DateTime end;

  Plan.fromJson(Map<String, dynamic> plan)
      : planID = plan["id"],
        clubID = plan["club_id"],
        clubName = plan["club_name"],
        userID = plan["user_id"],
        start = Utils.getFormattedDateFromFormattedString(
            value: plan["start"], isUtc: true),
        end = Utils.getFormattedDateFromFormattedString(
            value: plan["end"], isUtc: true);
}

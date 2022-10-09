import 'dart:developer';

import 'package:intl/intl.dart';

class Utils {
  static getFormattedDateFromFormattedString({required value, isUtc = false}) {
    String currentFormat = "yyyy-MM-ddTHH:mm:ssZ";
    // String desiredFormat = "yyyy-MM-dd HH:mm:ss";
    DateTime? dateTime = DateTime.now();
    if (value != null || value.isNotEmpty) {
      try {
        dateTime = DateFormat(currentFormat).parse(value, isUtc);
      } catch (e) {
        log("$e");
      }
    }
    return dateTime;
  }
}

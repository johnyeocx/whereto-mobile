import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/widgets/app_text.dart';

class Constants {
  static const String accessTokenKey = "access_token_key";
  static const String refreshTokenKey = "refresh_token_key";

  static const double searchBarFontSize = 18;
  // static const String serverEndpoint = "https://api.whereto.lol";
  // static const String wsEndpoint = "wss://api.whereto.lol";
  static const String serverEndpoint = "http://localhost:8080";
  static const String wsEndpoint = "ws://localhost:8080";

  static Widget backIcon = Container(
      width: 40,
      height: 40,
      color: AppColors.mainBgColor,
      child:
          const Center(child: FaIcon(FontAwesomeIcons.chevronLeft, size: 16)));

  static Function appBar = (title, context) {
    return AppBar(
      toolbarHeight: 50,
      title: AppText(
        text: title,
        fontSize: Constants.headerFontSize,
      ),
      backgroundColor: AppColors.mainBgColor,
      leading: GestureDetector(
        onTap: () async {
          // await widget.getUserFullFriends();
          Navigator.pop(context);
        },
        child: Constants.backIcon,
      ),
    );
  };

  static const double headerFontSize = 20;
}

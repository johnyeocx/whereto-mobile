import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/models/user.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/user_service.dart';
import 'package:where_to/widgets/app_text.dart';

class SearchResultTile extends StatefulWidget {
  final String username;
  final String receipientID;
  final FriendshipStatus status;
  const SearchResultTile(
      {Key? key,
      required this.username,
      required this.status,
      required this.receipientID})
      : super(key: key);

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  _handleButtonClicked() async {
    UserProvider? userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (widget.status == FriendshipStatus.full ||
        widget.status == FriendshipStatus.outwards) {
      // remove
      bool success = await UserService.removeFriendRequest(widget.receipientID);
      if (success) {
        userProvider.removeFriend(widget.receipientID, widget.status);
      }
    } else if (widget.status == FriendshipStatus.inwards ||
        widget.status == FriendshipStatus.none) {
      // add
      bool success = await UserService.addFriendRequest(widget.receipientID);
      if (success) {
        userProvider.addFriend(widget.receipientID, widget.status);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = AppColors.cyan;
    String prompt = "";
    FaIcon icon = const FaIcon(FontAwesomeIcons.check);
    if (widget.status == FriendshipStatus.full) {
      buttonColor = const Color.fromARGB(255, 121, 255, 159);
      prompt = "Friends";
      icon = FaIcon(
        FontAwesomeIcons.check,
        size: 14,
        color: buttonColor,
      );
    } else if (widget.status == FriendshipStatus.inwards) {
      buttonColor = Color.fromARGB(230, 255, 174, 212);
      prompt = "Add Back";
      icon = FaIcon(
        FontAwesomeIcons.plus,
        size: 14,
        color: buttonColor,
      );
    } else if (widget.status == FriendshipStatus.outwards) {
      buttonColor = AppColors.cyan;
      prompt = "Added";
      icon = FaIcon(
        FontAwesomeIcons.check,
        size: 14,
        color: buttonColor,
      );
    } else {
      buttonColor = AppColors.yellow;
      prompt = "Add";
      icon = FaIcon(
        FontAwesomeIcons.plus,
        size: 14,
        color: buttonColor,
      );
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 60, 60, 60), width: 0.5))),
        padding: const EdgeInsets.only(bottom: 10),
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: widget.username,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            GestureDetector(
                onTap: () {
                  _handleButtonClicked();
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: buttonColor,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    child: Row(
                      children: [
                        icon,
                        const SizedBox(width: 5),
                        AppText(
                          text: prompt,
                          color: buttonColor,
                          fontSize: 16,
                        )
                      ],
                    )))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/widgets/app_text.dart';

class FriendsGoingPage extends StatefulWidget {
  final List<dynamic> friends;
  const FriendsGoingPage({Key? key, required this.friends}) : super(key: key);

  @override
  State<FriendsGoingPage> createState() => _FriendsGoingPageState();
}

class _FriendsGoingPageState extends State<FriendsGoingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const AppText(
          text: "Friends Going Tonight",
          fontSize: Constants.headerFontSize,
        ),
        backgroundColor: AppColors.mainBgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Constants.backIcon,
        ),
      ),
      body: Container(
        color: AppColors.mainBgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: ListView.builder(
              itemCount: widget.friends.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade900, width: 1.5))),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 30,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: AppText(text: "${index + 1}."))),
                      AppText(text: "${widget.friends[index]["username"]}"),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

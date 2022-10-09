import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/models/user.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/user_service.dart';
import 'package:where_to/widgets/app_text.dart';

class OtherFriendsPage extends StatefulWidget {
  final String title;
  final Function getUserFullFriends;
  final bool isInwards;
  final Function addFriend;
  final Function removeFriend;
  const OtherFriendsPage(
      {Key? key,
      required this.isInwards,
      required this.title,
      required this.getUserFullFriends,
      required this.addFriend,
      required this.removeFriend})
      : super(key: key);

  @override
  State<OtherFriendsPage> createState() => _OtherFriendsPageState();
}

class _OtherFriendsPageState extends State<OtherFriendsPage> {
  List<dynamic>? users;
  bool _loading = true;

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  _getUsers() async {
    var res;
    if (widget.isInwards) {
      res = await UserService.getUserInwardFriendsReq();
    } else {
      res = await UserService.getUserOutwardFriendsReq();
    }

    if (res == null) {
      return;
    }

    setState(() {
      users = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserFriendships? userFriendships =
        Provider.of<UserProvider>(context).userFriendships;

    _toggleFriendAdded(status, receipientID, receipientName) async {
      UserProvider? userProvider =
          Provider.of<UserProvider>(context, listen: false);
      if (status == FriendshipStatus.full ||
          status == FriendshipStatus.outwards) {
        // remove
        bool success = await UserService.removeFriendRequest(receipientID);
        if (success) {
          userProvider.removeFriend(receipientID, status);
        }

        if (status == FriendshipStatus.full) {
          widget.removeFriend(receipientID);
        }
      } else if (status == FriendshipStatus.inwards ||
          status == FriendshipStatus.none) {
        // add
        bool success = await UserService.addFriendRequest(receipientID);
        if (success) {
          userProvider.addFriend(receipientID, status);
        }

        if (status == FriendshipStatus.inwards) {
          // get new friends planm
          // add to full friends
          Plan? friendPlan =
              await UserService.getFriendPlanRequest(receipientID);
          widget.addFriend({
            "id": receipientID,
            "username": receipientName,
          }, friendPlan);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        toolbarHeight: 50,
        title: AppText(
          text: widget.title,
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
      ),
      body: _loading
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: const BoxDecoration(color: AppColors.mainBgColor),
              child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.grey,
                size: 50,
              )))
          : users!.isEmpty
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: double.maxFinite,
                  decoration: const BoxDecoration(color: AppColors.mainBgColor),
                  child: Center(
                    child: AppText(
                      text: "None",
                      fontSize: 25,
                      color: Colors.grey.shade700,
                    ),
                  ))
              : Container(
                  color: AppColors.mainBgColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 35),
                    child: ListView.builder(
                        itemCount: users!.length,
                        itemBuilder: (context, index) {
                          String userId = users![index]["id"];
                          String username = users![index]["username"];

                          FriendshipStatus status = FriendshipStatus.none;
                          if (userFriendships!.full.contains(userId)) {
                            status = FriendshipStatus.full;
                          } else if (userFriendships.inwards.contains(userId)) {
                            status = FriendshipStatus.inwards;
                          } else if (userFriendships.outwards
                              .contains(userId)) {
                            status = FriendshipStatus.outwards;
                          }
                          bool isPending = status == FriendshipStatus.inwards ||
                              status == FriendshipStatus.none;

                          Color color =
                              isPending ? AppColors.cyan : AppColors.error;
                          String text = isPending ? "Add" : "Remove";
                          FaIcon icon = isPending
                              ? FaIcon(
                                  FontAwesomeIcons.plus,
                                  size: 14,
                                  color: color,
                                )
                              : FaIcon(
                                  FontAwesomeIcons.xmark,
                                  size: 14,
                                  color: color,
                                );

                          return SizedBox(
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: users![index]["username"],
                                  fontSize: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.5, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: color,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleFriendAdded(
                                        status,
                                        userId,
                                        username,
                                      );
                                    },
                                    child: Row(children: [
                                      icon,
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      AppText(
                                        text: text,
                                        color: color,
                                        fontSize: 18,
                                      )
                                    ]),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                ),
    );
  }
}

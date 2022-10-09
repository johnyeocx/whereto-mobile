import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/models/user.dart';
import 'package:where_to/pages/home/friends/other_friends_page.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/services/user_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:cancellation_token_http/http.dart' as http;
import 'package:where_to/widgets/friends/search_result_tile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<dynamic>? friends;
  List<dynamic>? inwardFriends;
  List<dynamic>? outwardFriends;
  Map<String, dynamic>? friendsMap;
  final FocusNode _focus = FocusNode();
  bool _isSearching = false;
  bool _friendsLoading = true;

  final TextEditingController _controller = TextEditingController();
  List<dynamic> searchResults = [];

  void _setIsSearching(bool val) {
    setState(() {
      _isSearching = val;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserFullFriends();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getUserFullFriends() async {
    var res = await UserService.getUserFullFriendsReq();
    setState(() {
      friends = res?["friends"];
      friendsMap = res?["friend_plans"];
      _friendsLoading = false;
    });
  }

  _addFriend(newFriend, friendPlan) {
    if (friends == null) return;

    bool isAlreadyIn = false;
    for (int i = 0; i < friends!.length; i++) {
      if (friends![i]["id"] == newFriend["id"]) {
        isAlreadyIn = true;
      }
    }

    if (!isAlreadyIn) {
      setState(() {
        friends!.add(newFriend);
      });
    }

    if (friendsMap != null && friendPlan != null) {
      friendsMap![newFriend["id"]] = friendPlan;
    }
  }

  _removeFriend(friendID) {
    if (friends == null) return;
    setState(() {
      friends!.removeWhere((element) => element["id"] == friendID);

      friendsMap!.remove(friendID);
    });
  }

  _onFocusChange() {
    setState(() {
      if (!_focus.hasFocus) {
        searchResults = [];
      }
    });
  }

  _toggleFriendAdded(status, receipientID) async {
    UserProvider? userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (status == FriendshipStatus.full ||
        status == FriendshipStatus.outwards) {
      // remove
      bool success = await UserService.removeFriendRequest(receipientID);
      if (success) {
        userProvider.removeFriend(receipientID, status);
      }
    } else if (status == FriendshipStatus.inwards ||
        status == FriendshipStatus.none) {
      // add
      bool success = await UserService.addFriendRequest(receipientID);
      if (success) {
        userProvider.addFriend(receipientID, status);
      }
    }
  }

  http.CancellationToken? cancelToken;
  _onSearchBarChanged(String q) async {
    if (q.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
    }

    if (q.isEmpty) {
      setState(() {
        _friendsLoading = true;
      });
      await _getUserFullFriends();
      setState(() {
        searchResults = [];
        _isSearching = false;
        _friendsLoading = false;
      });
      return;
    }

    if (cancelToken != null) {
      cancelToken?.cancel();
    }

    cancelToken = http.CancellationToken();

    try {
      Uri url = Uri.parse("${Constants.serverEndpoint}/api/users?q=$q");
      Map<String, String> authHeader = await AuthService.getAuthHeader();
      var res = await http.read(url,
          headers: authHeader, cancellationToken: cancelToken);

      var resDecoded = json.decode(res);

      setState(() {
        searchResults = resDecoded;
      });
    } on http.CancelledException {
      debugPrint("Cancelling request");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool userLoading = context.watch<UserProvider>().loading;
    bool loading = userLoading || _friendsLoading;

    UserFriendships? userFriendships =
        context.watch<UserProvider>().userFriendships!;

    return Scaffold(
        backgroundColor: AppColors.mainBgColor,
        appBar: AppBar(
          toolbarHeight: 15,
          backgroundColor: AppColors.mainBgColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.mainBgColor,
            child: Column(children: [
              _createSearchBar(
                focusNode: _focus,
                controller: _controller,
                onChange: _onSearchBarChanged,
                getFullFriends: _getUserFullFriends,
                setIsSearching: _setIsSearching,
              ),
              const SizedBox(height: 5),
              _isSearching
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Column(children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              String userId = searchResults[index]["id"];

                              FriendshipStatus status = FriendshipStatus.none;
                              if (userFriendships.full.contains(userId)) {
                                status = FriendshipStatus.full;
                              } else if (userFriendships.inwards
                                  .contains(userId)) {
                                status = FriendshipStatus.inwards;
                              } else if (userFriendships.outwards
                                  .contains(userId)) {
                                status = FriendshipStatus.outwards;
                              }

                              return SearchResultTile(
                                  receipientID: searchResults[index]["id"],
                                  status: status,
                                  username: searchResults[index]["username"]);
                            })
                      ]),
                    )
                  : Column(
                      children: [
                        _createFriendType("Add Back",
                            !loading ? userFriendships.inwards.length : null,
                            () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherFriendsPage(
                                  getUserFullFriends: _getUserFullFriends,
                                  title: "Add Back",
                                  isInwards: true,
                                  addFriend: _addFriend,
                                  removeFriend: _removeFriend,
                                ),
                              ));
                        }),
                        _createFriendType("Added",
                            !loading ? userFriendships.outwards.length : null,
                            () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherFriendsPage(
                                  getUserFullFriends: _getUserFullFriends,
                                  title: "Added",
                                  isInwards: false,
                                  addFriend: _addFriend,
                                  removeFriend: _removeFriend,
                                ),
                              ));
                        }),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              AppText(
                                text: loading
                                    ? "Friends"
                                    : "Friends (${userFriendships.full.length})",
                                fontSize: 18,
                                color: Colors.grey.shade200,
                              )
                            ],
                          ),
                        ),
                        if (loading)
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: SizedBox(
                              // height: 300,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: 2,
                                  itemBuilder: (context, index) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        height: 65,
                                        decoration: BoxDecoration(
                                            border: index != (2 - 1)
                                                ? const Border(
                                                    bottom: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 60, 60, 60),
                                                        width: 0.5))
                                                : null),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7.5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                  width: 150,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child:
                                                        LinearProgressIndicator(
                                                      color:
                                                          Colors.grey.shade900,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              100, 84, 83, 83),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        if (!loading && userFriendships.full.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: SizedBox(
                              // height: 300,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: friends!.length,
                                  itemBuilder: (context, index) {
                                    String friendId = friends?[index]["id"];
                                    Plan? plan = friendsMap?[friendId];
                                    bool isFriend =
                                        userFriendships.full.contains(friendId);

                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        height: 67,
                                        decoration: BoxDecoration(
                                            border: index !=
                                                    (friends!.length - 1)
                                                ? const Border(
                                                    bottom: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 60, 60, 60),
                                                        width: 0.5))
                                                : null),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7.5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AppText(
                                                  text: friends![index]
                                                      ["username"],
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 19,
                                                ),
                                                const SizedBox(height: 5),
                                                if (plan != null)
                                                  AppText(
                                                    text:
                                                        "Going: ${plan.clubName}",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: Colors.grey.shade500,
                                                  )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    FriendshipStatus status =
                                                        (isFriend
                                                            ? FriendshipStatus
                                                                .full
                                                            : FriendshipStatus
                                                                .inwards);
                                                    _toggleFriendAdded(
                                                        status, friendId);
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: isFriend
                                                                  ? AppColors
                                                                      .error
                                                                  : AppColors
                                                                      .cyan,
                                                              width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      child: isFriend
                                                          ? Row(
                                                              children: const [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .xmark,
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  size: 14,
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                AppText(
                                                                  text:
                                                                      "Remove",
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              children: const [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .plus,
                                                                  color:
                                                                      AppColors
                                                                          .cyan,
                                                                  size: 14,
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                AppText(
                                                                  text: "Add",
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color:
                                                                      AppColors
                                                                          .cyan,
                                                                ),
                                                              ],
                                                            )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                      ],
                    )
            ]),
          ),
        ));
  }
}

Widget _createSearchBar(
    {focusNode, controller, onChange, getFullFriends, setIsSearching}) {
  return Padding(
    padding: const EdgeInsets.only(left: 21, right: 21, top: 10, bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: SizedBox(
            height: 45,
            child: TextField(
              onEditingComplete: () {
                getFullFriends();
                focusNode.unfocus();
              },
              onChanged: onChange,
              focusNode: focusNode,
              controller: controller,
              textAlignVertical: TextAlignVertical.bottom,
              style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: Constants.searchBarFontSize,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      controller.text = "";
                      setIsSearching(false);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Color.fromARGB(255, 201, 201, 201),
                      size: 18,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 201, 201, 201),
                    size: 22,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 194, 194, 194),
                          width: 1.0),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 181, 181),
                          width: 1.0),
                      borderRadius: BorderRadius.circular(8)),
                  hintText: "Search Friends",
                  hintStyle: GoogleFonts.nunito(
                      fontSize: Constants.searchBarFontSize,
                      color: const Color.fromARGB(255, 201, 201, 201),
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _createFriendType(String title, int? amount, onPress) {
  return GestureDetector(
    onTap: () => onPress(),
    child: Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey.shade900, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: 18,
            color: Colors.grey.shade400,
          ),
          Row(
            children: [
              AppText(
                text: amount != null ? "$amount" : "",
                fontSize: 18,
                color: Colors.grey.shade400,
              ),
              const SizedBox(
                width: 10,
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 15,
                color: Colors.grey.shade400,
              )
            ],
          )
        ],
      ),
    ),
  );
}

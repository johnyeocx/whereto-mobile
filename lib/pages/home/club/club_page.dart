import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/misc/dimensions.dart';
import 'package:where_to/models/submissions.dart';

import 'package:where_to/providers/clubs_provider.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/clubs/club/sublist_tile.dart';
import 'package:where_to/widgets/clubs/club/submission_list.dart';
import 'package:where_to/widgets/clubs/club_dashboard.dart';
import 'package:where_to/widgets/clubs/club_header.dart';
import 'package:where_to/models/club.dart';

class ClubPage extends StatefulWidget {
  final Club club;
  const ClubPage({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final likesClub = false;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  IOWebSocketChannel? wsChannel;
  bool isOpen = false;

  final List<GlobalKey<AnimatedListState>> _listKeys = [
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
  ];

  final List<GlobalKey<AnimatedListState>> _listKeys2 = [
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
    GlobalKey<AnimatedListState>(),
  ];

  final List<List<Widget>> _catSubTiles = [[], [], [], []];

  void addListItem(dynamic submission, int stat) {
    _catSubTiles[stat].add(SubListTile(
        category: stat,
        listIndex: _catSubTiles[stat].length,
        sendWsMessage: _sendWsMessage));

    _listKeys[stat].currentState?.insertItem(_catSubTiles[stat].length - 1);
    _listKeys2[stat].currentState?.insertItem(_catSubTiles[stat].length - 1);
  }

  void _handleVoteMsg(dynamic msg, userID) {
    ClubSubmissionsProvider subProvider =
        Provider.of<ClubSubmissionsProvider>(context, listen: false);

    Map<String, int?> res = subProvider.handleVoteMsg(msg, userID);

    if (res["incStart"] != null) {
      int startIndex = res["incStart"]!;
      Future.delayed(const Duration(milliseconds: 0), () {
        _listKeys[msg["stat"] - 1].currentState?.removeItem(startIndex,
            ((context, animation) {
          return SizeTransition(
              sizeFactor: animation,
              child: _catSubTiles[msg["stat"] - 1][startIndex]);
        }), duration: const Duration(milliseconds: 150));
        _listKeys2[msg["stat"] - 1].currentState?.removeItem(startIndex,
            ((context, animation) {
          return SizeTransition(
              sizeFactor: animation,
              child: _catSubTiles[msg["stat"] - 1][startIndex]);
        }), duration: const Duration(milliseconds: 150));
      });

      Future.delayed(const Duration(milliseconds: 150), () {
        int endIndex =
            subProvider.reorderIncreasedVote(startIndex, msg["stat"]);
        _listKeys[msg["stat"] - 1]
            .currentState
            ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
        _listKeys2[msg["stat"] - 1]
            .currentState
            ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
        if (res["decStart"] != null) {
          int decStart = res["decStart"]!;
          if (decStart >= endIndex) {
            decStart += 1;
          }
          subProvider.reorderDecreasedVote(decStart, msg["stat"]);
        }
      });
    } else if (res["decStart"] != null) {
      int startIndex = res["decStart"]!;
      Future.delayed(const Duration(milliseconds: 0), () {
        _listKeys[msg["stat"] - 1].currentState?.removeItem(startIndex,
            ((context, animation) {
          return SizeTransition(
              sizeFactor: animation,
              child: _catSubTiles[msg["stat"] - 1][startIndex]);
        }), duration: const Duration(milliseconds: 150));
        _listKeys2[msg["stat"] - 1].currentState?.removeItem(startIndex,
            ((context, animation) {
          return SizeTransition(
              sizeFactor: animation,
              child: _catSubTiles[msg["stat"] - 1][startIndex]);
        }), duration: const Duration(milliseconds: 150));
      });

      Future.delayed(const Duration(milliseconds: 150), () {
        int endIndex =
            subProvider.reorderDecreasedVote(startIndex, msg["stat"]);
        _listKeys[msg["stat"] - 1]
            .currentState
            ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
        _listKeys2[msg["stat"] - 1]
            .currentState
            ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
      });
    }
  }

  void _handleUnvoteMsg(msg, userID, subProvider) {
    int? decStart = subProvider.handleUnvoteMsg(msg, userID);

    if (decStart == null) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 0), () {
      _listKeys[msg["stat"] - 1].currentState?.removeItem(decStart,
          ((context, animation) {
        return SizeTransition(
            sizeFactor: animation,
            child: _catSubTiles[msg["stat"] - 1][decStart]);
      }), duration: const Duration(milliseconds: 150));
      _listKeys2[msg["stat"] - 1].currentState?.removeItem(decStart,
          ((context, animation) {
        return SizeTransition(
            sizeFactor: animation,
            child: _catSubTiles[msg["stat"] - 1][decStart]);
      }), duration: const Duration(milliseconds: 150));
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      int endIndex = subProvider.reorderDecreasedVote(decStart, msg["stat"]);

      _listKeys[msg["stat"] - 1]
          .currentState
          ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
      _listKeys2[msg["stat"] - 1]
          .currentState
          ?.insertItem(endIndex, duration: const Duration(milliseconds: 150));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (wsChannel != null) {
      wsChannel!.sink.close(1001, "Done");
    }
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.club.isOpen()) {
        setState(() {
          isOpen = true;
        });
        myInitState();
      }
    });
    super.initState();
  }

  connectWS() async {
    Map<String, String> authHeaders = await AuthService.getAuthHeader();
    wsChannel = IOWebSocketChannel.connect(
        // Uri.parse('ws://localhost:8080/api/ws/club/${widget.club.id}'),
        Uri.parse('${Constants.wsEndpoint}/api/ws/club/${widget.club.id}'),
        headers: authHeaders);

    wsChannel!.stream.listen(
      (msg) {
        ClubSubmissionsProvider subProvider =
            Provider.of<ClubSubmissionsProvider>(context, listen: false);
        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);
        msg = json.decode(msg);

        if (msg["type"] == "submission") {
          Provider.of<ClubSubmissionsProvider>(context, listen: false)
              .addClubSubmission(msg);
          addListItem(msg["data"], msg["stat"] - 1);
        } else if (msg["type"] == "vote") {
          _handleVoteMsg(msg, userProvider.user!.userID);
        } else if (msg["type"] == "unvote") {
          _handleUnvoteMsg(msg, userProvider.user!.userID, subProvider);
        } else if (msg["type"] == "update_stat") {
          Provider.of<ClubsProvider>(context, listen: false)
              .updateClubStat(msg);
        } else if (msg["type"] == "close") {
          Provider.of<ClubsProvider>(context, listen: false)
              .setClubIsOpen(widget.club.id, false);

          setState(() {
            isOpen = false;
          });
        }
      },
      onError: (error) => log(error),
    );
  }

  myInitState() async {
    var subProvider =
        Provider.of<ClubSubmissionsProvider>(context, listen: false);

    await subProvider.setClubSubmissions(widget.club.id);
    await subProvider.setVotedSubmissions(widget.club.id);
    await subProvider.setFriendsGoing(widget.club.id);

    Map<FilterBy, List<Submission>>? submissions = subProvider.clubSubmissions;

    for (int i = 0; i < 4; i++) {
      List<Submission>? catSubs = submissions?[FilterBy.values[i + 1]];

      if (catSubs == null) {
        continue;
      }

      for (int j = 0; j < catSubs.length; j++) {
        _catSubTiles[i].add(SubListTile(
          category: i,
          listIndex: j,
          sendWsMessage: _sendWsMessage,
        ));

        _listKeys[i].currentState?.insertItem(_catSubTiles[i].length - 1);
        _listKeys2[i].currentState?.insertItem(_catSubTiles[i].length - 1);
      }
    }

    if (!widget.club.isOpen()) {
      return;
    }

    await connectWS();
  }

  void _sendWsMessage(data) {
    wsChannel!.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    ClubPageDimensions dimensions = ClubPageDimensions(context: context);
    void _handlePageChanged(value) {
      setState(() {
        _currentPage = value;
      });
    }

    final clubSubmissionsProvider =
        Provider.of<ClubSubmissionsProvider>(context);

    final club = widget.club;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: dimensions.headerHeight() - 60,
          automaticallyImplyLeading: false,
          flexibleSpace: ClubHeader(club: club),
          elevation: 0,
        ),
        backgroundColor: widget.club.isOpen()
            ? const Color.fromRGBO(0, 0, 0, 1)
            : AppColors.mainBgColor,
        body: !isOpen
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const Center(
                  child: AppTextHeader(
                    text: "Closed",
                  ),
                ),
              )
            : SafeArea(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClubDashboard(club: club),
                  if (clubSubmissionsProvider.clubSubmissions != null)
                    SubmissionList(
                      subProvider: clubSubmissionsProvider,
                      pageController: _pageController,
                      handlePageChanged: _handlePageChanged,
                      sendWsMessage: _sendWsMessage,
                      listKeys: _listKeys,
                      listKeys2: _listKeys2,
                      catSubTiles: _catSubTiles,
                      club: club,
                    ),
                  if (clubSubmissionsProvider.clubSubmissions != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 50, top: 15),
                      child: SizedBox(
                        height: 9,
                        width: 150,
                        child: Align(
                          alignment: Alignment.center,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    height: 5,
                                    width: _currentPage == index ? 20 : 9,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(4.5)),
                                  )),
                        ),
                      ),
                    )
                ],
              )));
  }
}

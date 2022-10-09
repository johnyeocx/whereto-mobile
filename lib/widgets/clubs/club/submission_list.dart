import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/dimensions.dart';

import 'package:where_to/models/club.dart';
import 'package:where_to/models/submissions.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/widgets/app_text.dart';

import 'package:where_to/widgets/clubs/club/submissions_modal.dart';
import 'package:where_to/widgets/clubs/club/submit_button.dart';

import '../../../providers/user_provider.dart';

class SubmissionList extends StatefulWidget {
  final ClubSubmissionsProvider subProvider;
  final PageController pageController;
  final Function(int) handlePageChanged;
  final Function(dynamic) sendWsMessage;
  final List<GlobalKey<AnimatedListState>> listKeys;
  final List<GlobalKey<AnimatedListState>> listKeys2;
  final List<List<Widget>> catSubTiles;
  final Club club;

  const SubmissionList({
    Key? key,
    required this.subProvider,
    required this.pageController,
    required this.handlePageChanged,
    required this.sendWsMessage,
    required this.listKeys,
    required this.listKeys2,
    required this.catSubTiles,
    required this.club,
  }) : super(key: key);

  @override
  State<SubmissionList> createState() => _SubmissionListState();
}

class _SubmissionListState extends State<SubmissionList> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final subsProvider = Provider.of<ClubSubmissionsProvider>(context);
    final voted = widget.subProvider.voted;
    Map<FilterBy, List<Submission>>? submissions =
        widget.subProvider.clubSubmissions;

    List<String> optionNames = [
      "Queue Time",
      "Current Genre",
      "Energy Levels",
      "Ratio"
    ];

    List<FaIcon> optionIcons = [
      const FaIcon(FontAwesomeIcons.clock, color: Colors.white, size: 18),
      const FaIcon(FontAwesomeIcons.music, color: Colors.white, size: 18),
      const FaIcon(FontAwesomeIcons.soundcloud, color: Colors.white, size: 18),
      const FaIcon(FontAwesomeIcons.person, color: Colors.white, size: 18),
    ];

    ClubPageDimensions dimensions = ClubPageDimensions(context: context);

    return Expanded(
        child: PageView.builder(
            onPageChanged: widget.handlePageChanged,
            scrollDirection: Axis.horizontal,
            controller: widget.pageController,
            itemCount: widget.catSubTiles.length,
            itemBuilder: (context, index) {
              Duration minElapsedTime = const Duration(minutes: 30);
              Duration? elapsedTime = hasRecentPost(
                  submissions?[FilterBy.values[index + 1]],
                  userProvider,
                  minElapsedTime);

              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 30, child: optionIcons[index]),
                              AppTextHeader(
                                text: optionNames[index],
                                fontSize: dimensions.statTypeSize(),
                              )
                            ],
                          ),
                          SubmitButton(
                              elapsedTime: elapsedTime,
                              minElapsedTime: minElapsedTime,
                              index: index,
                              sendWsMessage: widget.sendWsMessage)
                        ],
                      ),
                    ),
                    subsProvider.loading || submissions == null || voted == null
                        ? Expanded(
                            child: Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.grey,
                            size: 50,
                          )))
                        : submissions[FilterBy.values[index + 1]]!.isEmpty
                            ? Expanded(
                                child: Center(
                                child: AppText(
                                  text: "No Submissions Yet",
                                  fontSize: 25,
                                  color: Colors.grey[800],
                                ),
                              ))
                            : Expanded(
                                child: OpenContainer(
                                openBuilder: (context, closedContainer) {
                                  return SubmissionsModal(
                                    closeContainer: closedContainer,
                                    stat: index,
                                    listKeys: widget.listKeys2,
                                    catSubTiles: widget.catSubTiles,
                                  );
                                },
                                // openColor: theme.cardColor,
                                closedShape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                ),
                                closedElevation: 0,
                                openColor: Colors.black,
                                closedColor: Colors.black,
                                closedBuilder: (context, openContainer) {
                                  return GestureDetector(
                                      onTap: () {
                                        print("Tapped");
                                      },
                                      onPanUpdate: (details) {
                                        if (details.delta.dy < 0) {
                                          openContainer();
                                        }
                                      },
                                      child: Container(
                                        color: Colors.black,
                                        child: AnimatedList(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          key: widget.listKeys[index],
                                          initialItemCount:
                                              widget.catSubTiles[index].length,
                                          itemBuilder:
                                              (context, index2, animation) {
                                            return SizeTransition(
                                                sizeFactor: animation,
                                                child: widget.catSubTiles[index]
                                                    [index2]);
                                          },
                                        ),
                                      )

                                      //     Container(
                                      //   color: Colors.black,
                                      //   child: Dismissible(
                                      //     key: ObjectKey(
                                      //         FilterBy.values[index + 1]),
                                      //     dismissThresholds: const {
                                      //       DismissDirection.startToEnd: 0.8,
                                      //       DismissDirection.endToStart: 0.4,
                                      //     },
                                      //     background: Container(
                                      //       height: double.maxFinite,
                                      //       width: double.maxFinite,
                                      //       color: Colors.red,
                                      //     ),
                                      //     onDismissed: (direction) {
                                      //       switch (direction) {
                                      //         case DismissDirection.endToStart:
                                      //           // if (onStarredInbox) {
                                      //           // onStar();
                                      //           // }
                                      //           break;
                                      //         case DismissDirection.startToEnd:
                                      //           // onDelete();
                                      //           break;
                                      //         default:
                                      //       }
                                      //     },
                                      //     child: AnimatedList(
                                      //       physics:
                                      //           const NeverScrollableScrollPhysics(),
                                      //       key: widget.listKeys[index],
                                      //       initialItemCount:
                                      //           widget.catSubTiles[index].length,
                                      //       itemBuilder:
                                      //           (context, index2, animation) {
                                      //         return SizeTransition(
                                      //             sizeFactor: animation,
                                      //             child: widget.catSubTiles[index]
                                      //                 [index2]);
                                      //       },
                                      //     ),
                                      //   ),
                                      // ),
                                      );
                                },

                                // child: AnimatedList(
                                //   physics: const NeverScrollableScrollPhysics(),
                                //   key: widget.listKeys[index],
                                //   initialItemCount:
                                //       widget.catSubTiles[index].length,
                                //   itemBuilder: (context, index2, animation) {
                                //     return SizeTransition(
                                //         sizeFactor: animation,
                                //         child: widget.catSubTiles[index]
                                //             [index2]);
                                //   },
                                // ),
                              )),
                  ],
                ),
              );
            }));
  }
}

Duration? hasRecentPost(catSubs, userProvider, minElapsedTime) {
  if (catSubs == null) {
    return null;
  }

  for (int i = 0; i < catSubs!.length; i++) {
    Duration timeLapsed =
        DateTime.now().toUtc().difference(catSubs[i].timestamp);

    if (catSubs[i].username == userProvider.user?.username &&
        timeLapsed.compareTo(minElapsedTime) < 0) {
      return timeLapsed;
    }
  }
  return null;
}

// void _submitModalBottomSheet(context, index, sendWsMessage) {
//   showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext bc) {
//         return SubmitModal(
//             type: FilterBy.values[index], sendWsMessage: sendWsMessage);
//       });
// }

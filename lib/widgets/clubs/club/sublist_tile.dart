import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/dimensions.dart';
import 'package:where_to/models/submissions.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/widgets/app_text.dart';

class SubListTile extends StatefulWidget {
  final int category;
  final int listIndex;
  final Function(dynamic) sendWsMessage;

  const SubListTile({
    Key? key,
    required this.category,
    required this.listIndex,
    required this.sendWsMessage,
  }) : super(key: key);

  @override
  State<SubListTile> createState() => _SubListTileState();
}

class _SubListTileState extends State<SubListTile> {
  Color optionsColor = const Color(0xffEAC9FF);

  @override
  Widget build(BuildContext context) {
    dynamic voted = Provider.of<ClubSubmissionsProvider>(context).voted;
    Map<FilterBy, List<Submission>>? submissions =
        Provider.of<ClubSubmissionsProvider>(context).clubSubmissions!;

    var text = "";
    Submission? submission;
    if (widget.category == 0) {
      submission = submissions[FilterBy.queueTime]![widget.listIndex];
      text = "${submission.value}m";
    } else if (widget.category == 1) {
      submission = submissions[FilterBy.currentGenre]![widget.listIndex];
      text = "${submission.value}";
    } else if (widget.category == 2) {
      submission = submissions[FilterBy.energyLevels]![widget.listIndex];
      text = "${submission.value}";
    } else if (widget.category == 3) {
      submission = submissions[FilterBy.ratio]![widget.listIndex];
      text = "${submission.value[0]} : ${submission.value[1]}";
    }

    Duration timePassed = DateTime.now().difference(submission!.timestamp);
    String timePassedStr = "${timePassed.inSeconds}s";

    if (timePassed.inMinutes >= 1) {
      timePassedStr = "${timePassed.inMinutes}m";
    }
    if (timePassed.inHours >= 1) {
      timePassedStr = "${timePassed.inHours}h";
    }

    ClubPageDimensions dimensions = ClubPageDimensions(context: context);

    return Container(
        // height: dimensions.subHeightSize(),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 25, 25, 25)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // LEFT
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 20,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AppText(
                              textAlign: TextAlign.start,
                              text: "${widget.listIndex + 1}. ",
                              fontSize: dimensions.subValSize(),
                            ),
                          )),
                      AppText(
                        text: text,
                        fontSize: dimensions.subValSize(),
                      ),
                      // const SizedBox(width: 10),
                    ],
                  ),
                  AppText(
                      fontSize: dimensions.subInfoSize(),
                      color: Colors.grey.shade700,
                      text: "${submission.username}, $timePassedStr ago")
                ],
              ),
            ),
          ),

          // RIGHT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                  fontSize: dimensions.subValSize(),
                  color: optionsColor,
                  text: "${submission.votes}"),
              Checkbox(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(width: 2.0, color: optionsColor),
                  ),
                  activeColor: const Color.fromARGB(255, 248, 172, 255),
                  checkColor: const Color.fromARGB(255, 248, 172, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: voted[FilterBy.values[widget.category + 1]] ==
                      submission.id,
                  onChanged: (value) {
                    if (value == true) {
                      // toggle on
                      var message = {
                        "message_type": "vote",
                        "data": {
                          "submission_id": submission!.id,
                          "stat": widget.category + 1
                        }
                      };

                      widget.sendWsMessage(json.encode(message));
                    } else {
                      var message = {
                        "message_type": "unvote",
                        "data": {
                          "submission_id": submission!.id,
                          "stat": widget.category + 1
                        }
                      };

                      widget.sendWsMessage(json.encode(message));
                    }
                  }),
            ],
          )
        ]));
  }
}

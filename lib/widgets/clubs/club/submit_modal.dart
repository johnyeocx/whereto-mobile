import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/models/submissions.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/widgets/app_text.dart';

import '../../../providers/filters_provider.dart';

class Answers {
  static const queueTimes = [0, 10, 20, 30, 40, 50, 60, 90, 120];
  static const genres = [
    "Deep",
    "House",
    "Future House",
    "Deep House",
    "Progressive House",
    "Electro",
    "Trap"
  ];
  static const energyLevels = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static const ratio = [
    [1, 2, 3, 4, 5],
    [1, 2, 3, 4, 5]
  ];
}

class SubmitModal extends StatefulWidget {
  final FilterBy type;
  final Function(dynamic) sendWsMessage;
  const SubmitModal({Key? key, required this.type, required this.sendWsMessage})
      : super(key: key);

  @override
  State<SubmitModal> createState() => _SubmitModalState();
}

class _SubmitModalState extends State<SubmitModal> {
  var _selectedAnswer1 = 0;
  var _selectedAnswer2 = 0;
  String _ratioErr = "";

  @override
  Widget build(BuildContext context) {
    List<dynamic> answers = [];
    if (widget.type == FilterBy.queueTime) {
      answers = List.from(Answers.queueTimes);
    } else if (widget.type == FilterBy.currentGenre) {
      answers = List.from(Answers.genres);
    } else if (widget.type == FilterBy.energyLevels) {
      answers = List.from(Answers.energyLevels);
    } else if (widget.type == FilterBy.ratio) {
      answers = List.from(Answers.ratio);
    }

    // FILTER OUT
    Map<FilterBy, List<Submission>>? clubSubmissions =
        Provider.of<ClubSubmissionsProvider>(context).clubSubmissions;

    if (clubSubmissions == null) {
      return const AppText(text: "Error");
    }

    List<Submission>? submissions = clubSubmissions[widget.type];

    if (widget.type != FilterBy.ratio) {
      for (int i = 0; i < submissions!.length; i++) {
        if (answers.contains(submissions[i].value)) {
          answers.remove(submissions[i].value);
        }
      }
    }

    List<String> headerText = [
      "Queue Time (mins)",
      "Current Genre",
      "Energy Level",
      "Ratio (M : F)"
    ];

    _submitAnswer() async {
      setState(() {
        _ratioErr = "";
      });

      dynamic value;

      if (widget.type == FilterBy.queueTime) {
        value = answers[_selectedAnswer1] as int;
      } else if (widget.type == FilterBy.currentGenre) {
        value = answers[_selectedAnswer1] as String;
      } else if (widget.type == FilterBy.energyLevels) {
        value = answers[_selectedAnswer1] as int;
      } else if (widget.type == FilterBy.ratio) {
        value = [answers[0][_selectedAnswer1], answers[1][_selectedAnswer2]];
      }

      if (widget.type == FilterBy.ratio) {
        for (int i = 0; i < submissions!.length; i++) {
          double ratio = submissions[i].value[0] / submissions[i].value[1];
          double ans =
              answers[0][_selectedAnswer1] / answers[1][_selectedAnswer2];
          if (ans == ratio) {
            setState(() {
              _ratioErr =
                  "Similar ratio submitted (${submissions[i].value[0]} : ${submissions[i].value[1]})";
            });
            return;
          }
        }
      }

      Map<String, dynamic> message = {
        "message_type": "submission",
        "data": {"stat": widget.type.index, "value": value}
      };

      widget.sendWsMessage(json.encode(message));
      Navigator.pop(context);
    }

    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        color: AppColors.mainBgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: AppTextHeader(
                text: headerText[widget.type.index - 1],
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 22, left: 20, right: 20),
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(125, 93, 93, 93),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  widget.type == FilterBy.ratio
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    setState(() {
                                      _selectedAnswer1 = index;
                                    });
                                  });
                                },
                                itemExtent: 50,
                                perspective: 0.0003,
                                diameterRatio: 0.8,
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 5,
                                  builder: (context, index) =>
                                      ListTile("${index + 1}"),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: ListTile(":"),
                            ),
                            SizedBox(
                              width: 100,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    setState(() {
                                      _selectedAnswer2 = index;
                                    });
                                  });
                                },
                                itemExtent: 50,
                                perspective: 0.0003,
                                diameterRatio: 0.8,
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 5,
                                  builder: (context, index) =>
                                      ListTile("${index + 1}"),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListWheelScrollView.useDelegate(
                          onSelectedItemChanged: (index) {
                            setState(() {
                              // seletedItem = index;
                              _selectedAnswer1 = index;
                            });
                          },
                          itemExtent: 50,
                          perspective: 0.0003,
                          diameterRatio: 0.8,
                          physics: const FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: answers.length,
                            builder: (context, index) =>
                                ListTile("${answers[index]}"),
                          ),
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
              child: AppText(
                text:
                    "Once you submit an answer, you won't be able to submit another for 30 minutes",
                maxLines: 3,
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            if (widget.type == FilterBy.ratio && _ratioErr != "")
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
                child: AppText(
                    text: _ratioErr,
                    maxLines: 3,
                    fontSize: 15,
                    color: AppColors.error),
              ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                  color: AppColors.pink,
                  border: Border.all(color: AppColors.pink, width: 2),
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
                  onPressed: () {
                    _submitAnswer();
                  },
                  child: const AppTextHeader(
                    text: "Submit",
                    fontSize: 19,
                  )),
            )
          ],
        ));
  }
}

// ignore: non_constant_identifier_names
Widget ListTile([text]) {
  return Text(text,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5));
}

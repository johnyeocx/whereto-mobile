import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:where_to/misc/dimensions.dart';

import '../../models/club.dart';
import '../app_text.dart';

class ClubDashboard extends StatefulWidget {
  final Club club;
  const ClubDashboard({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubDashboard> createState() => _ClubDashboardState();
}

class _ClubDashboardState extends State<ClubDashboard> {
  double headerHeight = 150;
  double dashboardHeight = 220;
  Color optionsColor = const Color(0xffEAC9FF);

  @override
  Widget build(BuildContext context) {
    ClubPageDimensions dimensions = ClubPageDimensions(context: context);
    double titleFontSize = dimensions.statTitleSize();
    double valueFontSize = dimensions.statValueSize();
    if (!widget.club.isOpen()) {
      return const AppText(text: "");
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: dashboardHeight,
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 36, 35, 35),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              // TOP HALF
              Stack(
                children: [
                  Center(
                    child: Container(
                      height: dashboardHeight / 2,
                      width: MediaQuery.of(context).size.width - 80,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey, width: 2))),
                    ),
                  ),
                  SizedBox(
                    height: dashboardHeight / 2,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  height: dashboardHeight / 2 - 20,
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                          2,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: Colors.grey, width: 2))),
                                ),
                              ),
                              SizedBox(
                                height: dashboardHeight / 2,
                                width:
                                    (MediaQuery.of(context).size.width - 40) /
                                        2,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AppText(
                                          text: "Queue Time",
                                          fontSize: titleFontSize,
                                          color: optionsColor),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      AppText(
                                        text: widget.club.currentStats
                                                    .queueTime !=
                                                null
                                            ? "${widget.club.currentStats.queueTime!.value}m"
                                            : "-",
                                        fontSize: valueFontSize,
                                        maxLines: 2,
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          height: dashboardHeight / 2,
                          width: (MediaQuery.of(context).size.width - 40) / 2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AppText(
                                  text: "Current Genre",
                                  fontSize: titleFontSize,
                                  color: optionsColor,
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                AutoSizeText(
                                    widget.club.currentStats.currentGenre !=
                                            null
                                        ? "${widget.club.currentStats.currentGenre?.value}"
                                        : "-",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: GoogleFonts.nunito(
                                        fontSize: valueFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.5)),
                                // AppText(
                                //   text: widget.club.currentStats.currentGenre !=
                                //           null
                                //       ? "${widget.club.currentStats.currentGenre?.value}"
                                //       : "-",
                                //   fontSize: valueFontSize,
                                //   maxLines: 2,
                                // )
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // LOWER HALF
              SizedBox(
                height: dashboardHeight / 2,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: dashboardHeight / 2 - 20,
                              width:
                                  (MediaQuery.of(context).size.width - 40) / 2,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Colors.grey, width: 2))),
                            ),
                          ),
                          SizedBox(
                            height: dashboardHeight / 2,
                            width: (MediaQuery.of(context).size.width - 40) / 2,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppText(
                                    text: "Energy Level (0 - 10)",
                                    fontSize: titleFontSize,
                                    color: optionsColor,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AppText(
                                    text: widget.club.currentStats
                                                .energyLevel !=
                                            null
                                        ? "${widget.club.currentStats.energyLevel?.value}"
                                        : "-",
                                    fontSize: valueFontSize,
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: dashboardHeight / 2,
                      width: (MediaQuery.of(context).size.width - 40) / 2,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                                text: "Ratio (M : F)",
                                fontSize: titleFontSize,
                                color: optionsColor),
                            const SizedBox(
                              height: 10,
                            ),
                            AppText(
                              text: widget.club.currentStats.ratio != null
                                  ? "${widget.club.currentStats.ratio?.value[0]} : ${widget.club.currentStats.ratio?.value[1]}"
                                  : "-",
                              fontSize: valueFontSize,
                            )
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

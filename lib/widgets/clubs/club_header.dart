import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/dimensions.dart';
import 'package:where_to/models/plan.dart';
import 'package:where_to/pages/home/club/friends_going_page.dart';
import 'package:where_to/providers/clubs_provider.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/providers/submissions_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/club_service.dart';
import '../../models/club.dart';
import '../app_text.dart';

class ClubHeader extends StatefulWidget {
  final Club club;
  const ClubHeader({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubHeader> createState() => _ClubHeaderState();
}

class _ClubHeaderState extends State<ClubHeader> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    Map<String, bool> likedClubs =
        Provider.of<UserProvider>(context).likedClubs;
    Plan? userPlan = userProvider.userPlan;

    List<dynamic> friendsGoing =
        Provider.of<ClubSubmissionsProvider>(context).friendsGoing;

    toggleClubLiked() async {
      if (likedClubs[widget.club.id] == null || !likedClubs[widget.club.id]!) {
        bool res = await ClubService.likeClubReq(widget.club.id, true);
        if (res) {
          userProvider.likeClub(widget.club.id);
        }
      } else {
        bool res = await ClubService.likeClubReq(widget.club.id, false);
        if (res) {
          userProvider.unlikeClub(widget.club.id);
        }
      }
    }

    toggleGoingToClub() async {
      if (userPlan != null &&
          userPlan.clubID == widget.club.id &&
          userPlan.end.isAfter(DateTime.now().toUtc()) &&
          userPlan.start.isBefore(DateTime.now().toUtc())) {
        Plan? res = await ClubService.cancelPlanReq(widget.club.id);
        if (res != null && res.clubID == widget.club.id) {
          userProvider.setUserPlan(null);
        }
      } else {
        List<DateTime>? timing = widget.club.getStartAndEnd();

        if (timing == null) {
          return;
        }

        DateTime start =
            timing[0].subtract(Duration(hours: widget.club.timezoneOffset));
        DateTime end =
            timing[1].subtract(Duration(hours: widget.club.timezoneOffset));

        Plan? newPlan =
            await ClubService.goingClubReq(widget.club.id, start, end);

        if (newPlan != null) {
          userProvider.setUserPlan(newPlan);
        }
      }
    }

    handlePeopleGoingClicked() {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendsGoingPage(
              friends: friendsGoing,
            ),
          ));
    }

    handleBackClicked() {
      FilterBy filter =
          Provider.of<Filters>(context, listen: false).filterOption;

      bool showLikedOnly =
          Provider.of<Filters>(context, listen: false).showLikedOnly;

      var userLocation =
          Provider.of<UserProvider>(context, listen: false).user?.location;

      if (userLocation != null) {
        Provider.of<ClubsProvider>(context, listen: false)
            .setClubs(filter.index, userLocation, showLikedOnly);
      }

      Navigator.pop(context);
    }

    ClubPageDimensions dimensions = ClubPageDimensions(context: context);
    double headerHeight = dimensions.headerHeight();
    // const double headerPaddingBottom = 10;

    bool isGoing = userPlan != null && userPlan.clubID == widget.club.id;
    return Stack(
      children: [
        Container(
          height: headerHeight,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(widget.club.image()), fit: BoxFit.cover)),
        ),
        Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.15, 0.6, 0.95],
                colors: <Color>[
                  Color.fromRGBO(0, 0, 0, 0.95),
                  Color.fromRGBO(0, 0, 0, 0.95),
                  Color.fromRGBO(0, 0, 0, 0.6),
                  Color.fromRGBO(0, 0, 0, 0),
                ],
                tileMode: TileMode.mirror,
              ),
            )),
        SizedBox(
          height: headerHeight,
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 10),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK BUTTON
                    GestureDetector(
                      onTap: () {
                        handleBackClicked();
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: 30,
                        height: 40,
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: FaIcon(
                            FontAwesomeIcons.chevronLeft,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CLUB NAME
                        Container(
                          padding: const EdgeInsets.only(left: 1),
                          child: AppTextHeader(
                            text: widget.club.name,
                            fontSize: dimensions.headerTitleSize(),
                          ),
                        ),
                        const SizedBox(height: 5),

                        // LOCATION
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              child: Align(
                                alignment: Alignment.center,
                                child: FaIcon(FontAwesomeIcons.locationPin,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 5),
                            AppText(
                              text: widget.club.address,
                              fontSize: dimensions.infoSize(),
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // LIKE BUTTON
                            Container(
                              padding: const EdgeInsets.only(left: 2),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      toggleClubLiked();
                                    },
                                    child: Container(
                                      width: 85,
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          top: 3,
                                          bottom: 3,
                                          right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              // width: 1.5,
                                              color:
                                                  likedClubs[widget.club.id] ==
                                                          true
                                                      ? AppColors.liked
                                                      : Colors.white)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 15,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Transform.scale(
                                                scaleX: 1,
                                                scaleY: 0.9,
                                                child: likedClubs[
                                                            widget.club.id] ==
                                                        true
                                                    ? const FaIcon(
                                                        FontAwesomeIcons
                                                            .wineGlass,
                                                        color: AppColors.liked,
                                                        size: 17,
                                                      )
                                                    : const FaIcon(
                                                        FontAwesomeIcons
                                                            .wineGlassEmpty,
                                                        color: Colors.white,
                                                        size: 17,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          likedClubs[widget.club.id] == true
                                              ? AppText(
                                                  text: "Liked",
                                                  fontSize: dimensions
                                                      .buttonTitleSize(),
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.liked,
                                                )
                                              : AppText(
                                                  text: "Like",
                                                  fontSize: dimensions
                                                      .buttonTitleSize(),
                                                  fontWeight: FontWeight.w600,
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // GOING
                            if (widget.club.isOpen())
                              GestureDetector(
                                onTap: () {
                                  toggleGoingToClub();
                                },
                                child: Container(
                                  width: 90,
                                  padding: const EdgeInsets.only(
                                      left: 10, top: 3, bottom: 3, right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          // width: 1.5,
                                          color: isGoing
                                              ? AppColors.cyan
                                              : Colors.white)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        child: userPlan != null &&
                                                userPlan.clubID ==
                                                    widget.club.id &&
                                                userPlan.end.isAfter(
                                                    DateTime.now().toUtc()) &&
                                                userPlan.start.isBefore(
                                                    DateTime.now().toUtc())
                                            ? const FaIcon(
                                                FontAwesomeIcons
                                                    .solidPaperPlane,
                                                color: AppColors.cyan,
                                                size: 14)
                                            : const FaIcon(
                                                FontAwesomeIcons.paperPlane,
                                                color: Colors.white,
                                                size: 14),
                                      ),
                                      SizedBox(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: userPlan != null &&
                                                  userPlan.clubID ==
                                                      widget.club.id
                                              ? AppText(
                                                  fontWeight: FontWeight.w600,
                                                  text: "Going",
                                                  fontSize: dimensions
                                                      .buttonTitleSize(),
                                                  color: AppColors.cyan,
                                                )
                                              : AppText(
                                                  fontWeight: FontWeight.w600,
                                                  text: "Go",
                                                  fontSize: dimensions
                                                      .buttonTitleSize(),
                                                ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            handlePeopleGoingClicked();
                          },
                          child: Row(
                            children: [
                              const Center(
                                child: FaIcon(FontAwesomeIcons.userGroup,
                                    color: Colors.white, size: 13),
                              ),
                              const SizedBox(width: 5),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: AppText(
                                    text: "${friendsGoing.length}",
                                    fontSize: dimensions.buttonTitleSize(),
                                    fontWeight: FontWeight.w800,
                                  ))
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/pages/account/account_page.dart';
import 'package:where_to/pages/home/club/club_page.dart';
import 'package:where_to/pages/home/home_page.dart';
import 'package:where_to/providers/clubs_provider.dart';

import 'package:where_to/widgets/app_text.dart';
import 'package:cancellation_token_http/http.dart' as http;
import '../../misc/app_colors.dart';
import '../../models/club.dart';
import '../../providers/filters_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/clubs/filter_modal.dart';

Color optionsColor = const Color(0xffEAC9FF);

class ClubsPage extends StatefulWidget {
  final Function(bool) setIsLoggedIn;
  final GlobalKey<ScaffoldState> drawerKey;
  const ClubsPage(
      {Key? key, required this.setIsLoggedIn, required this.drawerKey})
      : super(key: key);

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  List<Club> qClubs = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  _refreshList() async {
    await getClubs();
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<DrawerItem> drawerItems = [
    DrawerItem(
        icon: const FaIcon(FontAwesomeIcons.universalAccess,
            color: Colors.white, size: 20),
        title: "Account"),
    DrawerItem(
        icon:
            const FaIcon(FontAwesomeIcons.gear, color: Colors.white, size: 18),
        title: "Settings")
  ];

  http.CancellationToken? cancelToken;

  _onSearchBarChanged(String q) async {
    if (q.isEmpty) {
      setState(() {
        qClubs = [];

        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    if (cancelToken != null) {
      cancelToken?.cancel();
    }

    cancelToken = http.CancellationToken();
    Position? userPos = context.read<UserProvider>().user?.location;

    if (userPos == null) {
      return;
    }

    try {
      Uri url = Uri.parse(
          "${Constants.serverEndpoint}/api/clubs/q?q=$q&longitude=${userPos.longitude}&latitude=${userPos.latitude}");

      // Map<String, String> authHeader = await AuthService.getAuthHeader();
      var res = await http.read(url, cancellationToken: cancelToken);

      var resDecoded = json.decode(res);

      List<Club> newClubs = [];
      for (int i = 0; i < resDecoded.length; i++) {
        newClubs.add(Club.fromJson(resDecoded[i]));
      }
      setState(() {
        qClubs = newClubs;
      });
    } on http.CancelledException {
      debugPrint("Cancelling request");
    }
  }

  @override
  void initState() {
    getClubs();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getClubs() async {
    final userModel = Provider.of<UserProvider>(context, listen: false);
    final clubModel = Provider.of<ClubsProvider>(context, listen: false);
    final filterModel = Provider.of<Filters>(context, listen: false);
    await clubModel.setClubs(filterModel.filterOption.index,
        userModel.user!.location!, filterModel.showLikedOnly);
  }

  @override
  Widget build(BuildContext context) {
    final clubsProvider = Provider.of<ClubsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    bool loading = clubsProvider.loading || userProvider.loading;

    if (loading) {
      return Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(color: AppColors.mainBgColor),
          child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.grey,
            size: 50,
          )));
    }
    List<Club> shownClubs = [];
    if (_isSearching) {
      shownClubs = qClubs;
    } else {
      shownClubs = clubsProvider.clubs!;
    }

    return Scaffold(
      key: _key,
      appBar: getHomeAppBar(context),
      body: Container(
          width: double.maxFinite,
          decoration: const BoxDecoration(color: AppColors.mainBgColor),
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 10, top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: _controller,
                          onChanged: _onSearchBarChanged,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: GoogleFonts.nunito(
                              fontSize: Constants.searchBarFontSize,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _controller.text = "";
                                  setState(() {
                                    _isSearching = false;
                                  });
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
                              hintText: "Search Clubs",
                              hintStyle: GoogleFonts.nunito(
                                  fontSize: Constants.searchBarFontSize,
                                  color:
                                      const Color.fromARGB(255, 201, 201, 201),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                        onPressed: () {
                          _filterModalBottomSheet(context);
                        },
                        icon: const FaIcon(FontAwesomeIcons.arrowDownShortWide,
                            color: Color.fromARGB(255, 201, 201, 201),
                            size: 18))
                  ],
                ),
              ),
              // const SizedBox(height: 20),
              Expanded(
                child: CustomRefreshIndicator(
                  notificationPredicate:
                      !_isSearching ? (_) => true : (_) => false,
                  builder: (context, child, controller) {
                    return AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, _) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            if (!controller.isIdle)
                              Positioned(
                                top: 35.0 * controller.value,
                                child: SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: const Color.fromARGB(
                                        255, 158, 158, 158),
                                    value: !controller.isLoading
                                        ? controller.value.clamp(0.0, 1.0)
                                        : null,
                                  ),
                                ),
                              ),
                            Transform.translate(
                              offset: Offset(0, 100.0 * controller.value),
                              child: child,
                            ),
                          ],
                        );
                      },
                    );
                  },
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    return _refreshList();
                  },
                  child: RawScrollbar(
                    thumbColor: const Color.fromARGB(255, 152, 152, 152),
                    radius: const Radius.circular(20),
                    thickness: 10,
                    child: ListView.builder(
                      itemCount: shownClubs.length,
                      itemBuilder: (context, index) {
                        Club club = shownClubs[index];
                        ClubStats currentStats = shownClubs[index].currentStats;
                        double deviceWidth = MediaQuery.of(context).size.width;
                        double imgWidth = deviceWidth * 0.22;
                        double infoWidth = deviceWidth * 0.5;
                        double titleFontSize = deviceWidth * 0.048;
                        double infoFontSize = deviceWidth * 0.04;
                        double rightFontSize = deviceWidth * 0.043;
                        double rightWidth = deviceWidth * 0.2;

                        String rightText = "-";
                        if (!club.isOpen()) {
                          rightText = "Closed";
                        } else if (context.watch<Filters>().filterOption ==
                            FilterBy.likes) {
                          rightText = "";
                        } else if (context.watch<Filters>().filterOption ==
                                FilterBy.queueTime &&
                            currentStats.queueTime != null) {
                          rightText = "${currentStats.queueTime!.value}m";
                        } else if (context.watch<Filters>().filterOption ==
                                FilterBy.currentGenre &&
                            currentStats.currentGenre != null) {
                          rightText = currentStats.currentGenre!.value;
                        } else if (context.watch<Filters>().filterOption ==
                                FilterBy.energyLevels &&
                            currentStats.energyLevel != null) {
                          rightText = "${currentStats.energyLevel!.value}";
                        } else if (context.watch<Filters>().filterOption ==
                                FilterBy.ratio &&
                            currentStats.ratio != null) {
                          rightText =
                              "${currentStats.ratio!.value[0]}M : ${currentStats.ratio!.value[1]}F";
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClubPage(club: club),
                                  ));
                            },
                            child: Container(
                                height: imgWidth + 40,
                                width: double.maxFinite,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color:
                                                Color.fromARGB(255, 87, 87, 87),
                                            width: 1))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15, right: 10),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // LEFT SIDE
                                        SizedBox(
                                          width: imgWidth + infoWidth,
                                          child: Row(children: [
                                            SizedBox(
                                              height: imgWidth,
                                              width: imgWidth,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                      fit: BoxFit.cover,
                                                      club.image())),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              // color: Colors.red,
                                              width: infoWidth - 20,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AppText(
                                                    text: club.name,
                                                    fontSize: titleFontSize,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                        width: 20,
                                                        child: FaIcon(
                                                            FontAwesomeIcons
                                                                .locationPin,
                                                            color: Colors.white,
                                                            size: 15),
                                                      ),
                                                      Flexible(
                                                        child: AppText(
                                                          text: club.address,
                                                          fontSize:
                                                              infoFontSize,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        child: userProvider.likedClubs[
                                                                        club
                                                                            .id] !=
                                                                    null &&
                                                                userProvider
                                                                        .likedClubs[
                                                                    club.id]!
                                                            ? const FaIcon(
                                                                FontAwesomeIcons
                                                                    .wineGlass,
                                                                color: AppColors
                                                                    .liked,
                                                                size: 16)
                                                            : const FaIcon(
                                                                FontAwesomeIcons
                                                                    .wineGlass,
                                                                color: Colors
                                                                    .white,
                                                                size: 16),
                                                      ),
                                                      AppText(
                                                        text:
                                                            "${club.likesCount}",
                                                        fontSize: infoFontSize,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                        SizedBox(
                                          width: rightWidth - 20,
                                          child: !club.isOpen()
                                              ? AppText(
                                                  text: "Closed",
                                                  color: const Color.fromARGB(
                                                      255, 150, 132, 175),
                                                  fontWeight: FontWeight.w800,
                                                  maxLines: 2,
                                                  fontSize: rightFontSize,
                                                )
                                              : AppText(
                                                  text: rightText,
                                                  color: optionsColor,
                                                  fontWeight: FontWeight.w800,
                                                  maxLines: 2,
                                                  fontSize: rightFontSize,
                                                ),
                                          // ListView.builder(
                                          //     itemCount: 2,
                                          //     physics:
                                          //         const NeverScrollableScrollPhysics(),
                                          //     shrinkWrap: true,
                                          //     itemBuilder:
                                          //         (context, index) {
                                          //       return SizedBox(
                                          //         width: rightWidth - 20,
                                          //         child: AppText(
                                          //           text: "Progressive",
                                          //           color: optionsColor,
                                          //           fontWeight:
                                          //               FontWeight.w800,
                                          //           maxLines: 1,
                                          //           fontSize:
                                          //               rightFontSize,
                                          //         ),
                                          //       );
                                          //     },
                                        ),
                                      ]),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

void _filterModalBottomSheet(context) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return const FilterModal();
      });
}

AppBar getHomeAppBar(context) {
  return AppBar(
    toolbarHeight: 60,
    elevation: 0,
    leading: null,
    actions: [
      Padding(
          padding: const EdgeInsets.only(right: 25.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountPage(),
                  ));
            },
            child: const Icon(
              Icons.person_rounded,
              size: 25,
            ),
          )),
    ],
    flexibleSpace: Container(
        height: double.maxFinite,
        color: AppColors.mainBgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Image.asset('images/title_logo.png', width: 110),
              ),
            ],
          ),
        )),
  );
}

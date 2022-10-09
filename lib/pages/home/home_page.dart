import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/pages/home/clubs_page.dart';
import 'package:where_to/pages/home/friends/friends_page.dart';

import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/storage_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/drawer_tile.dart';

class HomePage extends StatefulWidget {
  final void Function(bool) setIsLoggedIn;
  const HomePage({Key? key, required this.setIsLoggedIn}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class DrawerItem {
  FaIcon icon;
  String title;
  DrawerItem({required this.icon, required this.title});
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0;
  final Geolocator geolocator = Geolocator();

  List<DrawerItem> drawerItems = [
    DrawerItem(
        icon: const FaIcon(FontAwesomeIcons.universalAccess,
            color: Colors.white, size: 20),
        title: "Account"),
  ];

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    void _onTabItemTapped(int index) {
      setState(() {
        selectedTabIndex = index;
      });
    }

    return Scaffold(
      key: _drawerKey,
      // drawer: getHomeDrawer(context, userProvider, drawerItems, storageService,
      //     widget.setIsLoggedIn),
      body: user == null
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: const BoxDecoration(color: AppColors.mainBgColor),
              child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.grey,
                size: 50,
              )))
          : selectedTabIndex == 0
              ? ClubsPage(
                  setIsLoggedIn: widget.setIsLoggedIn, drawerKey: _drawerKey)
              : selectedTabIndex == 1
                  ? const FriendsPage()
                  : Container(
                      color: AppColors.mainBgColor,
                      child: const AppText(text: "random")),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.mainBgColor,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.compactDisc,
                          size: 24,
                        ),
                      ),
                    ),
                    label: 'Clubs'),
                BottomNavigationBarItem(
                    icon: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.userGroup,
                          size: 18,
                        ),
                      ),
                    ),
                    label: 'Friends')
              ],
              currentIndex: selectedTabIndex,
              onTap: _onTabItemTapped,
            )),
      ),
    );
  }
}

AppBar getHomeAppBar(key) {
  return AppBar(
    toolbarHeight: 50,
    elevation: 0,
    leading: GestureDetector(
      onTap: () {/* Write listener code here */},
    ),
    actions: [
      Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              key.currentState!.openDrawer();
            },
            child: const Icon(Icons.menu),
          )),
    ],
    flexibleSpace: Container(
        height: double.maxFinite,
        color: AppColors.mainBgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Image.asset('images/title_logo.png', width: 100),
              ),
            ],
          ),
        )),
  );
}

Drawer getHomeDrawer(
    context, userModel, drawerItems, storageService, setIsLoggedIn) {
  return Drawer(
      width: MediaQuery.of(context).size.width * .6,
      backgroundColor: AppColors.mainBgColor,
      child: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
          height: 110,
          child: DrawerHeader(
            padding: const EdgeInsets.only(left: 20, top: 30),
            decoration: const BoxDecoration(color: AppColors.mainBgColor),
            child: AppTextHeader(
              text: "${userModel.user?.username}",
              fontSize: 20,
            ),
          ),
        ),

        SizedBox(
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              shrinkWrap: true,
              itemCount: drawerItems.length,
              itemBuilder: (BuildContext context, int index) {
                return DrawerTile(
                  icon: drawerItems[index].icon,
                  title: drawerItems[index].title,
                );
              }),
        ),

        const SizedBox(height: 10),

        // LOGOUT BUTTON
        GestureDetector(
          onTap: () {
            storageService.deleteSecureData(Constants.accessTokenKey);
            storageService.deleteSecureData(Constants.refreshTokenKey);
            // widget.setIsLoggedIn(false);
            setIsLoggedIn(false);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.pink, width: 1.5)),
            child: const Center(
                child: AppText(text: "Log Out", color: AppColors.pink)),
          ),
        )
      ]));
}

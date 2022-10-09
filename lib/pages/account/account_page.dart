import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/pages/account/new_password_page.dart';
import 'package:where_to/pages/account/new_username_page.dart';
import 'package:where_to/providers/auth_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/storage_service.dart';
import 'package:where_to/widgets/app_text.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();
    StorageService storageService = StorageService();

    List selections = [
      {
        "title": "Username",
        "onPress": () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewUsernamePage(),
              ));
        }
      },
      {
        "title": "Password",
        "onPress": () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewPasswordPage(),
              ));
        }
      }
    ];

    if (userProvider.user == null) {
      return const AppText(text: "Loading");
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: AppText(
          text: context.read<UserProvider>().user!.username,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
        backgroundColor: AppColors.mainBgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Constants.backIcon,
        ),
      ),
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
          child: Container(
              height: double.maxFinite,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: AppTextHeader(
                        text: "Edit Account",
                        fontSize: 20,
                      )),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: selections.length,
                      itemBuilder: (context, index) {
                        return _createChangeButton(selections[index]["title"],
                            selections[index]["onPress"]);
                      }),
                  GestureDetector(
                    onTap: () async {
                      await storageService
                          .deleteSecureData(Constants.accessTokenKey);
                      await storageService
                          .deleteSecureData(Constants.refreshTokenKey);
                      // widget.setIsLoggedIn(false);
                      context.read<AuthProvider>().toggleIsLoggedIn(false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.error, width: 1.5),
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      child: const AppText(
                        text: "Log Out",
                        color: AppColors.error,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                ],
              ))),
    );
  }
}

Widget _createChangeButton(title, onPress) {
  return GestureDetector(
    onTap: onPress,
    child: Container(
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
          FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 15,
            color: Colors.grey.shade400,
          )
        ],
      ),
    ),
  );
}

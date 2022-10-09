// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/models/user.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/user_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/auth/auth_textfield.dart';

import '../../misc/app_colors.dart';

class NewUsernamePage extends StatefulWidget {
  const NewUsernamePage({Key? key}) : super(key: key);

  @override
  State<NewUsernamePage> createState() => _NewUsernamePageState();
}

class _NewUsernamePageState extends State<NewUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;
  String error = "";

  _changeUsername() async {
    String? prevUsername = context.read<UserProvider>().user?.username;
    String newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() {
        error = "Username can't be empty";
      });
      return;
    }

    if (prevUsername == null || prevUsername == newUsername) {
      setState(() {
        error = "Username is the same as last";
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    int resCode = await UserService.changeUsernameRequest(newUsername);

    if (resCode == 409) {
      setState(() {
        error = "Username already exists";
      });
    } else if (resCode == 200) {
      context.read<UserProvider>().setUsername(newUsername);
      Navigator.pop(context);
    } else {
      setState(() {
        error = "Failed to change username";
      });
    }
    setState(() {
      _loading = false;
    });
    return;
  }

  @override
  void initState() {
    User? user = context.read<UserProvider>().user;
    if (user != null) {
      _usernameController.text = user.username;
    }

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const AppText(
          text: "Username",
          fontSize: Constants.headerFontSize,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Column(children: [
          AuthTextField(
            underlineColor: error.isNotEmpty ? AppColors.error : AppColors.cyan,
            hintText: "New Username",
            controller: _usernameController,
            horizontalPadding: 25,
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: error, color: AppColors.error),
              ),
            ),
          GestureDetector(
            onTap: () {
              _changeUsername();
            },
            child: Container(
              height: 45,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Center(
                child: _loading
                    ? const UnconstrainedBox(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : const AppText(
                        text: "Save",
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

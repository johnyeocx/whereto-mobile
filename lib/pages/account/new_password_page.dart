import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/services/user_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/auth/auth_textfield.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({Key? key}) : super(key: key);

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _loading = false;
  Map<int, String> _error = {};

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  _handleChangePasswordClicked() async {
    setState(() {
      _error = {};
    });
    String oldPw = _oldPasswordController.text.trim();
    String newPw = _newPasswordController.text.trim();
    String cfmPw = _confirmPasswordController.text.trim();

    if (oldPw.isEmpty) {
      setState(() {
        _error[0] = "";
      });
    }
    if (newPw.isEmpty) {
      setState(() {
        _error[1] = "";
      });
    }

    var errors = _error.values.toList();
    var numErrors = errors.where((e) => e != null).length;
    if (numErrors > 0) {
      return;
    }

    if (newPw != cfmPw) {
      setState(() {
        _error[2] = "Passwords don't match";
      });
      return;
    }

    setState(() {
      _loading = true;
    });
    int resCode = await UserService.changePasswordRequest(oldPw, newPw);
    if (resCode == 403) {
      setState(() {
        _loading = false;
        _error[0] = "Old password is incorrect";
      });
      return;
    } else if (resCode == 200) {
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
      return;
    } else {
      setState(() {
        _error[3] = "Failed to change password";
        _loading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const AppText(
          text: "Password",
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
            obscureText: true,
            underlineColor:
                _error[0] != null ? AppColors.error : AppColors.cyan,
            hintText: "Old Password",
            controller: _oldPasswordController,
            horizontalPadding: 25,
          ),
          if (_error[0] != null && _error[0] != "")
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: _error[0]!, color: AppColors.error),
              ),
            ),
          AuthTextField(
            obscureText: true,
            underlineColor:
                _error[1] != null ? AppColors.error : AppColors.cyan,
            hintText: "New Password",
            controller: _newPasswordController,
            horizontalPadding: 25,
          ),
          if (_error[1] != null && _error[1] != "")
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: _error[1]!, color: AppColors.error),
              ),
            ),
          AuthTextField(
            obscureText: true,
            underlineColor:
                _error[2] != null ? AppColors.error : AppColors.cyan,
            hintText: "Confirm Password",
            controller: _confirmPasswordController,
            horizontalPadding: 25,
          ),
          if (_error[2] != null && _error[2] != "")
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: _error[2]!, color: AppColors.error),
              ),
            ),
          if (_error[3] != null && _error[3]!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: _error[3]!, color: AppColors.error),
              ),
            ),
          GestureDetector(
            onTap: () {
              _handleChangePasswordClicked();
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

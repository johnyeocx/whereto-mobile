import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/auth/auth_button.dart';
import 'package:where_to/widgets/auth/auth_textfield.dart';

import '../../misc/constants.dart';
import '../../services/storage_service.dart';

class ResetPage extends StatefulWidget {
  Function(bool) setIsLoggedIn;
  ResetPage({Key? key, required this.setIsLoggedIn}) : super(key: key);

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  TextEditingController emailController = TextEditingController();
  var _signupError = {};
  var _success = false;
  var _loading = false;

  bool emailIsValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void _handleResetClicked() async {
    String email = emailController.text.trim();
    Map<int, String> signupError = {};

    // VALIDATION
    if (email == "") {
      signupError[0] = "";
    }

    if (!emailIsValid(emailController.text.trim())) {
      signupError[0] = "Invalid email";
    }

    if (signupError.isNotEmpty) {
      setState(() {
        _signupError = signupError;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    Map? result = await AuthService.getResetEmailRequest(email);

    if (result == null) {
      setState(() {
        _success = true;
      });
    } else if (result["error"] != null) {
      setState(() {
        _signupError = result["error"];
      });
      return;
    }

    setState(() {
      _signupError = {};
    });

    setState(() {
      _loading = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });

    return;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.mainBgColor,
        body: SafeArea(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppTextHeader(text: "Reset your password"),
              const SizedBox(height: 20),
              AuthTextField(
                  underlineColor:
                      (_signupError[0] != null && _signupError[0] != null)
                          ? AppColors.error
                          : AppColors.cyan,
                  hintText: "Email",
                  controller: emailController),
              if (_signupError[0] != null)
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        AppText(text: _signupError[0], color: AppColors.error),
                  ),
                ),
              if (_success == true)
                const Padding(
                  padding: EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                        text: "Successfully sent reset email!",
                        color: Colors.white),
                  ),
                ),
              const SizedBox(height: 20),
              AuthButton(
                  buttonText: "Reset Email",
                  loading: _loading,
                  buttonClicked: _handleResetClicked),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text("Back to login",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 16))
                    ],
                  )),
            ],
          )),
        ));
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/providers/auth_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/widgets/app_text.dart';
import 'package:where_to/widgets/auth/auth_button.dart';
import 'package:where_to/widgets/auth/auth_textfield.dart';

import '../../misc/constants.dart';
import '../../services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  Function(bool) setIsLoggedIn;
  RegisterPage({Key? key, required this.setIsLoggedIn}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _storageService = StorageService();
  bool _loading = false;

  var _signupError = {};

  bool emailIsValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void _handleSignupClicked() async {
    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    Map<int, String> signupError = {};

    setState(() {
      _signupError = {};
    });

    // VALIDATION
    if (email == "") {
      signupError[0] = "";
    }
    if (username == "") {
      signupError[1] = "";
    }
    if (password == "") {
      signupError[2] = "";
    }

    if (!emailIsValid(emailController.text.trim())) {
      signupError[0] = "Invalid email";
    }
    if (password != confirmPassword) {
      signupError[3] = "Passwords don't match";
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
    Map result = await AuthService.signupRequest(username, email, password);
    if (result["error"] != null) {
      setState(() {
        _signupError = result["error"];
      });
      return;
    }

    setState(() {
      _signupError = {};
      _loading = false;
    });

    _storageService.writeSecureData(
        StorageItem(Constants.accessTokenKey, result["accessToken"]));

    _storageService.writeSecureData(
        StorageItem(Constants.refreshTokenKey, result["refreshToken"]));

    final userModel = Provider.of<UserProvider>(context, listen: false);
    final userSuccess = await userModel.setUser();
    if (!userSuccess) {
      setState(() {
        _loading = false;
      });
      return;
    }

    Navigator.of(context).pop();
    context.read<AuthProvider>().toggleIsLoggedIn(true);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              const AppTextHeader(text: "Make your first move."),
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
              AuthTextField(
                  underlineColor: (_signupError[1] != null)
                      ? AppColors.error
                      : AppColors.cyan,
                  hintText: "Username",
                  controller: usernameController),
              if (_signupError[1] != null && _signupError[1] != "")
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        AppText(text: _signupError[1], color: AppColors.error),
                  ),
                ),
              AuthTextField(
                  underlineColor: (_signupError[2] != null)
                      ? AppColors.error
                      : AppColors.cyan,
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController),
              if (_signupError[2] != null && _signupError[2] != "")
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        AppText(text: _signupError[2], color: AppColors.error),
                  ),
                ),
              AuthTextField(
                  underlineColor: (_signupError[3] != null)
                      ? AppColors.error
                      : AppColors.cyan,
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPasswordController),
              if (_signupError[3] != null && _signupError[3] != "")
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        AppText(text: _signupError[3], color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 20),
              AuthButton(
                  buttonText: "Sign Up",
                  loading: _loading,
                  buttonClicked: _handleSignupClicked),
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

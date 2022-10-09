// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';

import 'package:where_to/pages/auth/register.dart';
import 'package:where_to/pages/auth/reset.dart';
import 'package:where_to/providers/auth_provider.dart';
import 'package:where_to/providers/user_provider.dart';
import 'package:where_to/services/auth_service.dart';
import 'package:where_to/services/storage_service.dart';
import 'package:where_to/widgets/auth/auth_button.dart';
import 'package:where_to/widgets/auth/auth_textfield.dart';

import '../../widgets/app_text.dart';

Future<String> loadAsset() async {
  return await rootBundle.loadString('images/title_logo.png');
}

class LoginPage extends StatefulWidget {
  final void Function(bool) setIsLoggedIn;

  const LoginPage({Key? key, required this.setIsLoggedIn}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginError = {"error": 0, "message": ""};
  final _storageService = StorageService();
  bool _loading = false;

  void handleLoginClicked() async {
    setState(() {
      loginError["error"] = 0;
      loginError["message"] = "";
      _loading = true;
    });

    Map result = await AuthService.loginRequest(
        emailController.text.trim(), passwordController.text.trim());

    if (result["error"] != null) {
      setState(() {
        loginError["error"] = result["error"];
        loginError["message"] = result["message"];
      });

      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      loginError["error"] = 0;
      loginError["message"] = "";
    });

    _storageService.writeSecureData(
        StorageItem(Constants.accessTokenKey, result["accessToken"]));

    _storageService.writeSecureData(
        StorageItem(Constants.refreshTokenKey, result["refreshToken"]));

    final userModel = Provider.of<UserProvider>(context, listen: false);
    final userSuccess = await userModel.setUser();
    print(userSuccess);
    if (!userSuccess) {
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      loginError["error"] = 0;
      loginError["message"] = "";
      _loading = false;
    });

    context.read<AuthProvider>().toggleIsLoggedIn(true);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 15, 15),
        body: SafeArea(
            child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Hello Again
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset('images/title_logo.png', width: 180),
            ),
            SizedBox(height: 20),

            // Email TextField
            AuthTextField(
                underlineColor: (loginError["error"] == 1)
                    ? AppColors.error
                    : AppColors.cyan,
                hintText: "Username / Email",
                obscureText: false,
                controller: emailController),
            if (loginError["error"] == 1)
              Padding(
                padding: EdgeInsets.only(left: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                      text: loginError["message"] as String,
                      color: AppColors.error),
                ),
              ),

            // Password TextField
            AuthTextField(
                underlineColor: (loginError["error"] == 2)
                    ? AppColors.error
                    : AppColors.cyan,
                hintText: "Password",
                obscureText: true,
                controller: passwordController),
            if (loginError["error"] == 2)
              Padding(
                padding: EdgeInsets.only(left: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                      text: loginError["message"] as String,
                      color: AppColors.error),
                ),
              ),

            SizedBox(height: 10),

            AuthButton(
                buttonText: "Login",
                loading: _loading,
                buttonClicked: handleLoginClicked),

            SizedBox(
              height: 30,
              child: GestureDetector(
                  onTap: () {
                    _registerModalBottomSheet(context, widget.setIsLoggedIn);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white)),
                      Text("Sign up here",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white))
                    ],
                  )),
            ),
            SizedBox(
              height: 30,
              child: GestureDetector(
                  onTap: () {
                    _resetModalBottomSheet(context, widget.setIsLoggedIn);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Forgot your password? ",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade600)),
                      Text("Reset it here",
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey.shade600))
                    ],
                  )),
            ),
          ]),
        )));
  }
}

void _registerModalBottomSheet(context, setIsLoggedIn) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return RegisterPage(setIsLoggedIn: setIsLoggedIn);
      });
}

void _resetModalBottomSheet(context, setIsLoggedIn) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return ResetPage(setIsLoggedIn: setIsLoggedIn);
      });
}

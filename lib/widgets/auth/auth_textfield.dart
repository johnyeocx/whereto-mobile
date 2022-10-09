import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:where_to/misc/app_colors.dart';

class AuthTextField extends StatelessWidget {
  // const MyWidget({Key? key}) : super(key: key);

  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Color? underlineColor;
  final double? horizontalPadding;

  const AuthTextField(
      {Key? key,
      required this.hintText,
      this.obscureText = false,
      required this.controller,
      this.underlineColor = AppColors.cyan,
      this.horizontalPadding = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _buildTextField(
      hintText: hintText,
      obscureText: obscureText,
      controller: controller,
      underlineColor: underlineColor!,
      horizontalPadding: horizontalPadding!);
}

Widget _buildTextField(
    {required String hintText,
    required bool obscureText,
    required TextEditingController controller,
    required Color underlineColor,
    required double horizontalPadding}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15),
    child: Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: underlineColor))),
      child: TextField(
        textInputAction: TextInputAction.next,
        style: GoogleFonts.nunito(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(
                fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}

// Widget OtherText()
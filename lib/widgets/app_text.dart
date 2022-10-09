import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextHeader extends StatelessWidget {
  final String text;
  final double? fontSize;
  const AppTextHeader({Key? key, required this.text, this.fontSize = 27})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5));
  }
}

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;

  const AppText(
      {Key? key,
      required this.text,
      this.fontSize = 16,
      this.color = Colors.white,
      this.fontWeight = FontWeight.w700,
      this.maxLines = 1,
      this.textAlign = TextAlign.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        softWrap: false,
        style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: -0.5));
  }
}

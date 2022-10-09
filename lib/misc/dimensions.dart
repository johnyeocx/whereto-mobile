import 'package:flutter/material.dart';

class ClubPageDimensions {
  BuildContext context;
  ClubPageDimensions({required this.context});

  double header = 0.275;
  double headerTitle = 0.07;
  double info = 0.047;
  double buttonTitle = 0.04;

  double headerHeight() {
    return MediaQuery.of(context).size.height * header;
  }

  double headerTitleSize() {
    return MediaQuery.of(context).size.width * headerTitle;
  }

  double infoSize() {
    return MediaQuery.of(context).size.width * info;
  }

  double buttonTitleSize() {
    return MediaQuery.of(context).size.width * buttonTitle;
  }

  double statTitle = 0.04;
  double statTitleSize() {
    return MediaQuery.of(context).size.width * statTitle;
  }

  double statValue = 0.055;
  double statValueSize() {
    return MediaQuery.of(context).size.width * statValue;
  }

  double statType = 0.05;
  double statTypeSize() {
    return MediaQuery.of(context).size.width * statType;
  }

  double subHeight = 0.18;
  double subHeightSize() {
    return MediaQuery.of(context).size.width * subHeight;
  }

  double subInfo = 0.042;
  double subInfoSize() {
    return MediaQuery.of(context).size.width * subInfo;
  }

  double subVal = 0.045;
  double subValSize() {
    return MediaQuery.of(context).size.width * subVal;
  }
}

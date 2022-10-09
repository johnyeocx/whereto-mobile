import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:where_to/widgets/app_text.dart';

class Countdown extends StatefulWidget {
  final Duration timeLeft;
  final Function resetElapsedTime;
  const Countdown(
      {Key? key, required this.timeLeft, required this.resetElapsedTime})
      : super(key: key);

  @override
  State<Countdown> createState() => CountdownState();
}

class CountdownState extends State<Countdown> {
  Timer? countdownTimer;
  Duration? myDuration;

  @override
  void initState() {
    myDuration = super.widget.timeLeft;
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    // stopTimer();
    countdownTimer!.cancel();
    super.dispose();
  }

  /// Timer related methods ///
  // Step 3
  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  // // Step 4
  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  // Step 6
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration!.inSeconds - reduceSecondsBy;
      if (seconds <= 0) {
        countdownTimer!.cancel();
        widget.resetElapsedTime();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits(myDuration!.inMinutes.remainder(60));
    final seconds = strDigits(myDuration!.inSeconds.remainder(60));
    return AppText(text: "$minutes:$seconds", color: Colors.grey.shade600);
  }
}

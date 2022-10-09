import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/widgets/clubs/club/countdown.dart';
import 'package:where_to/widgets/clubs/club/submit_modal.dart';

class SubmitButton extends StatefulWidget {
  Duration? elapsedTime;
  Duration minElapsedTime;
  Function sendWsMessage;
  int index;
  SubmitButton(
      {super.key,
      required this.elapsedTime,
      required this.index,
      required this.sendWsMessage,
      required this.minElapsedTime});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  Duration? elapsedTime;
  @override
  void initState() {
    setState(() {
      elapsedTime = widget.elapsedTime;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SubmitButton oldWidget) {
    setState(() {
      elapsedTime = widget.elapsedTime;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    void setElapsedTimeToNull() {
      setState(() {
        elapsedTime = null;
      });
    }

    return SizedBox(
      height: 30,
      child: elapsedTime != null &&
              elapsedTime!.compareTo(widget.minElapsedTime) < 0
          ? Center(
              child: Countdown(
                  timeLeft: widget.minElapsedTime - elapsedTime!,
                  resetElapsedTime: setElapsedTimeToNull),
            )
          : Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    _submitModalBottomSheet(
                        context, widget.index + 1, widget.sendWsMessage);
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus,
                      color: AppColors.options, size: 18)),
            ),
    );
  }
}

void _submitModalBottomSheet(context, index, sendWsMessage) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return SubmitModal(
            type: FilterBy.values[index], sendWsMessage: sendWsMessage);
      });
}

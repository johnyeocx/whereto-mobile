import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:where_to/misc/app_colors.dart';
import 'package:where_to/misc/constants.dart';
import 'package:where_to/providers/filters_provider.dart';
import 'package:where_to/widgets/app_text.dart';

class SubmissionsModal extends StatefulWidget {
  final Function closeContainer;
  final int stat;
  final List<GlobalKey<AnimatedListState>> listKeys;
  final List<List<Widget>> catSubTiles;
  const SubmissionsModal(
      {super.key,
      required this.closeContainer,
      required this.stat,
      required this.listKeys,
      required this.catSubTiles});

  @override
  State<SubmissionsModal> createState() => _SubmissionsModalState();
}

class _SubmissionsModalState extends State<SubmissionsModal> {
  @override
  Widget build(BuildContext context) {
    List<String> headerTitle = [
      "Queue Time",
      "Current Genre",
      "Energy Level",
      "Ratio"
    ];
    return GestureDetector(
        onPanUpdate: (details) {
          // Swiping in right direction.

          // Swiping in left direction.
          if (details.delta.dy > 0) {
            widget.closeContainer();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: Constants.appBar(headerTitle[widget.stat], context),
          body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: AnimatedList(
                physics: const NeverScrollableScrollPhysics(),
                key: widget.listKeys[widget.stat],
                initialItemCount: widget.catSubTiles[widget.stat].length,
                itemBuilder: (context, index2, animation) {
                  return SizeTransition(
                      sizeFactor: animation,
                      child: widget.catSubTiles[widget.stat][index2]);
                },
              )),
        ));
  }
}

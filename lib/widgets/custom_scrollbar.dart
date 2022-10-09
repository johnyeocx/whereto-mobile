import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomScrollBar extends StatefulWidget {
  final BoxScrollView Function(ScrollController controller) builder;
  const CustomScrollBar({Key? key, required this.builder}) : super(key: key);

  @override
  State<CustomScrollBar> createState() => _CustomScrollBarState();
}

class _CustomScrollBarState extends State<CustomScrollBar> {
  late ScrollController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar(
      controller: controller,
      backgroundColor: Colors.white,
      heightScrollThumb: 200,
      scrollThumbBuilder: scrollThumbBuilder,
      child: widget.builder(controller),
    );
  }
}

Widget scrollThumbBuilder(
        Color backgroundColor,
        Animation<double> thumbAnimation,
        Animation<double> labelAnimation,
        double height,
        {Text? labelText,
        BoxConstraints? labelConstraints}) =>
    Container(
      height: height,
      width: 12,
      color: backgroundColor,
    );

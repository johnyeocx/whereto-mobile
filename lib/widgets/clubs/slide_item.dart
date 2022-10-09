import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:where_to/widgets/app_text.dart';

class SlideItem extends StatefulWidget {
  const SlideItem({Key? key}) : super(key: key);

  @override
  State<SlideItem> createState() => _SlideItemState();
}

class _SlideItemState extends State<SlideItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [AppText(text: "1"), Text("2"), Text("3")],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:where_to/pages/account/account_page.dart';
import 'package:where_to/widgets/app_text.dart';

class DrawerTile extends StatefulWidget {
  final FaIcon icon;
  final String title;
  const DrawerTile({Key? key, required this.icon, required this.title})
      : super(key: key);

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountPage(),
            ));
      },
      child: ListTile(
          title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // const Icon(Icons.person, color: Colors.white, size: 18),
        SizedBox(width: 30, child: Center(child: widget.icon)),
        const SizedBox(width: 12),
        AppText(
          text: widget.title,
        ),
      ])),
    );
  }
}
